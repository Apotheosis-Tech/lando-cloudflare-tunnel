# Troubleshooting Guide

## Common Issues and Solutions

### 🔧 Installation Issues

#### cloudflared not found
```bash
# macOS
brew install cloudflared

# Ubuntu/Debian
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# Manual installation
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
chmod +x cloudflared
sudo mv cloudflared /usr/local/bin/
```

#### Authentication failed
```bash
# Login to Cloudflare
cloudflared tunnel login

# Check authentication
cloudflared tunnel list

# If browser doesn't open, copy the URL manually
```

### 🌐 Tunnel Issues

#### Tunnel won't start
```bash
# Check if another tunnel is running
ps aux | grep cloudflared
pkill cloudflared

# Check tunnel exists
cloudflared tunnel list

# Recreate tunnel if corrupted
cloudflared tunnel delete your-tunnel-name
./smart-start.sh
```

#### "tunnel already exists" error
```bash
# List existing tunnels
cloudflared tunnel list

# Delete old tunnel
cloudflared tunnel delete TUNNEL-ID

# Create new tunnel
./smart-start.sh
```

#### DNS not resolving
```bash
# Check DNS propagation
nslookup your-domain.com
dig your-domain.com

# Manually set DNS (if you have access)
cloudflared tunnel route dns your-tunnel-name your-domain.com

# Wait 5-10 minutes for DNS propagation
```

### 🔌 Connectivity Issues

#### External domain returns 502/503
- **Cause:** Lando not running or tunnel misconfigured
- **Solution:**
  ```bash
  lando start
  ./tunnel-status.sh
  ./health-check.sh
  ```

#### External domain times out
- **Cause:** DNS not configured or tunnel not running
- **Solution:**
  ```bash
  cloudflared tunnel route dns your-tunnel-name your-domain.com
  ./smart-start.sh
  ```

#### Local site works but external doesn't
- **Cause:** Tunnel configuration pointing to wrong local URL
- **Solution:**
  ```bash
  # Check Lando info
  lando info
  
  # Verify tunnel config
  cat ~/.cloudflared/config.yml
  
  # Restart tunnel
  ./stop-tunnel.sh
  ./smart-start.sh
  ```

#### External domain returns 404
- **Cause:** Tunnel pointing to `*.lndo.site` instead of `localhost:PORT`
- **Solution:**
  ```bash
  # CRITICAL FIX: Use localhost instead of *.lndo.site
  # The *.lndo.site domains often return 400 Bad Request
  
  # Stop tunnel
  pkill cloudflared
  
  # Fix config to use localhost
  sed -i.bak 's/http:\/\/.*\.lndo\.site/http:\/\/localhost:PORT/' ~/.cloudflared/config.yml
  
  # Restart tunnel
  ./smart-start.sh
  ```

#### "Speaking plain HTTP to an SSL-enabled server"
- **Cause:** Server expects HTTPS but tunnel sends HTTP
- **Solution:**
  ```bash
  # Update tunnel config to use HTTPS
  sed -i.bak 's/http:\/\/localhost/https:\/\/localhost/' ~/.cloudflared/config.yml
  
  # Or let smart-start.sh auto-detect protocol
  ./smart-start.sh
  ```

### 🐛 Lando Issues

#### Can't detect Lando port
```bash
# Check Lando status
lando info

# Manually specify port
export LANDO_PORT=8080
./smart-start.sh

# Check for port conflicts
lando stop
lando start
```

#### Permission denied errors
```bash
# Make scripts executable
chmod +x *.sh

# Check file ownership
ls -la *.sh

# Fix ownership if needed
sudo chown $USER:$USER *.sh
```

### 📱 OAuth/Application Issues

#### OAuth callbacks failing
1. **Check redirect URI** in your app settings
   - Should be: `https://your-domain.com/oauth/callback`
   - NOT: `http://yourapp.lndo.site/oauth/callback`

2. **Verify Drupal configuration**
   ```php
   // In settings.local.php
   $base_url = 'https://your-domain.com';
   $config['your_oauth_module.settings']['dev_base_url'] = 'https://your-domain.com';
   ```

3. **Clear Drupal cache**
   ```bash
   lando drush cr
   ```

#### Facebook OAuth specific issues
- **Invalid redirect URI:** Update Facebook app settings
- **App not in development mode:** Switch to development mode in Facebook
- **Wrong app ID/secret:** Verify credentials in settings.local.php

### 💻 Platform-Specific Issues

#### macOS Issues
```bash
# Homebrew permission issues
brew doctor
brew update

# macOS firewall blocking
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off
```

#### Linux Issues
```bash
# systemd-resolved conflicts
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved

# AppArmor blocking
sudo aa-complain /usr/local/bin/cloudflared
```

#### Windows (WSL) Issues
```bash
# WSL networking issues
# Use Windows cloudflared.exe instead of Linux version
./cloudflared.exe tunnel run your-tunnel

# Port forwarding issues
netsh interface portproxy add v4tov4 listenport=80 listenaddress=0.0.0.0 connectport=80 connectaddress=localhost
```

### 🔍 Debugging Commands

#### Check tunnel health
```bash
./health-check.sh
./tunnel-status.sh
```

#### View logs
```bash
# Tunnel logs
tail -f /tmp/cloudflare-tunnel-your-project.log

# Lando logs
lando logs -f
```

#### Test connectivity
```bash
# Test local
curl -I http://yourapp.lndo.site

# Test external
curl -I https://your-domain.com

# Test with verbose output
curl -v https://your-domain.com
```

#### Network diagnostics
```bash
# Check ports
netstat -tulpn | grep :80
lsof -i :80

# Check DNS
nslookup your-domain.com
dig your-domain.com

# Check SSL
openssl s_client -servername your-domain.com -connect your-domain.com:443
```

### 🆘 Getting Help

#### Enable debug logging
```bash
# Add to tunnel config
echo "log-level: debug" >> ~/.cloudflared/config.yml

# Restart tunnel
./stop-tunnel.sh
./smart-start.sh
```

#### Collect diagnostic info
```bash
# Run health check
./health-check.sh > debug-info.txt

# Add Lando info
lando info >> debug-info.txt

# Add tunnel config
cat ~/.cloudflared/config.yml >> debug-info.txt

# Add recent logs
tail -50 /tmp/cloudflare-tunnel-your-project.log >> debug-info.txt
```

#### Community resources
- [Lando Slack](https://launchpass.com/devwithlando)
- [Cloudflare Community](https://community.cloudflare.com/)
- [GitHub Issues](https://github.com/your-repo/issues)

Remember: Most issues are solved by restarting Lando and the tunnel! 🔄
