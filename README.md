# Lando Cloudflare Tunnel Integration

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A complete solution for integrating **Cloudflare Tunnels** with **Lando** development environments. Get stable, permanent external URLs for your local development - no more random ngrok URLs that break your OAuth callbacks!

## 🎯 **Why Use This?**

- ✅ **Stable URLs** - Your external URL never changes
- ✅ **OAuth Friendly** - Perfect for Facebook, Google, GitHub OAuth flows  
- ✅ **No Port Conflicts** - Works regardless of Lando's assigned ports
- ✅ **HTTPS by Default** - Automatic SSL certificates
- ✅ **Team Friendly** - Share consistent URLs with your team
- ✅ **Free** - Cloudflare tunnels are free for development use
- ✅ **Battle Tested** - Successfully resolves common 404 and connectivity issues

> **🎉 Real Success Story**: This package was battle-tested while fixing a Facebook OAuth integration. The key breakthrough was discovering that `*.lndo.site` domains return 400 Bad Request errors, but `localhost:PORT` works perfectly. The package now automatically detects the correct protocol (HTTP/HTTPS) and uses localhost connections for maximum reliability.

## 🚀 **Quick Start**

### Prerequisites
- [Lando](https://lando.dev/) installed and working
- [Cloudflare account](https://cloudflare.com) (free)
- [cloudflared CLI](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/) installed

### Installation

1. **Install cloudflared:**
   ```bash
   # macOS
   brew install cloudflared
   
   # Linux
   wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
   sudo dpkg -i cloudflared-linux-amd64.deb
   ```

2. **Authenticate with Cloudflare:**
   ```bash
   cloudflared tunnel login
   ```

3. **Copy the scripts to your Lando project:**
   ```bash
   # Copy all shell scripts to your Lando project root
   cp *.sh /path/to/your/lando/project/
   chmod +x *.sh
   ```

4. **Configure your domain:**
   Edit the scripts and replace `your-project.your-domain.com` with your desired subdomain.

5. **Start your tunnel:**
   ```bash
   ./smart-start.sh
   ```

## 📁 **What's Included**

### Core Scripts

- **`smart-start.sh`** - Auto-detects Lando port and starts tunnel (interactive)
- **`start-background.sh`** - Runs tunnel in background with logging
- **`stop-tunnel.sh`** - Stops tunnel and optionally Lando
- **`tunnel-status.sh`** - Check tunnel status and health

### Configuration

- **`settings-example.php`** - Drupal settings for reverse proxy
- **`config-example.yml`** - Cloudflare tunnel configuration template

### Utilities

- **`setup-domain.sh`** - Interactive domain configuration
- **`health-check.sh`** - Verify tunnel and local connectivity

## 🔧 **Configuration**

### 1. Domain Setup

The package supports any domain you own in Cloudflare:

```bash
# Examples:
your-project.yourdomain.com
dev.yourcompany.com  
myapp-local.example.org
```

### 2. Drupal Integration

For Drupal projects, add this to your `settings.local.php`:

```php
# Enable reverse proxy support
$settings['reverse_proxy'] = TRUE;
$settings['reverse_proxy_addresses'] = ['127.0.0.1', '::1', 'localhost'];
$settings['reverse_proxy_trusted_headers'] = 30;

# Add your tunnel domain to trusted hosts
$settings['trusted_host_patterns'][] = '^your-project\.your-domain\.com$';

# Force external URL
$base_url = 'https://your-project.your-domain.com';
```

### 3. OAuth Configuration

Perfect for OAuth applications! Your redirect URIs will be:
```
https://your-project.your-domain.com/oauth/callback
https://your-project.your-domain.com/auth/facebook/callback
```

## 🛠️ **Advanced Usage**

### Multiple Projects

Each project can have its own subdomain:
```bash
# Project A
projecta.mydev.com

# Project B  
projectb.mydev.com

# Staging
staging.myproject.com
```

### Team Development

Share the same external URL across your team:
1. One person sets up the tunnel with a team domain
2. Team members use the same configuration
3. Everyone gets the same external URL structure

### CI/CD Integration

Use in GitHub Actions or other CI systems:
```yaml
- name: Start Cloudflare Tunnel
  run: |
    ./start-background.sh
    ./health-check.sh
```

## 📋 **Commands Reference**

| Command | Purpose |
|---------|---------|
| `./smart-start.sh` | Start tunnel (interactive, shows logs) |
| `./start-background.sh` | Start tunnel in background |
| `./stop-tunnel.sh` | Stop tunnel |
| `./tunnel-status.sh` | Check if tunnel is running |
| `./health-check.sh` | Test connectivity |
| `./setup-domain.sh` | Configure domain settings |

## 🐛 **Troubleshooting**

### Tunnel Won't Start
```bash
# Check if cloudflared is installed
cloudflared --version

# Check authentication
cloudflared tunnel list

# View logs
tail -f /tmp/cloudflare-tunnel.log
```

### Port Detection Issues
```bash
# Manually check Lando info
lando info

# Override port detection
export LANDO_PORT=8080
./smart-start.sh
```

### Domain Resolution Problems
```bash
# Test DNS resolution
nslookup your-project.your-domain.com

# Check tunnel connectivity
curl -I https://your-project.your-domain.com
```

## 🔒 **Security Notes**

- Tunnels expose your local development to the internet
- Use strong authentication in your applications
- Consider IP restrictions for sensitive projects
- Don't commit tunnel credentials to version control

## 🤝 **Contributing**

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Test with multiple Lando configurations  
4. Submit a pull request

## 📄 **License**

MIT License - see LICENSE file for details.

## 🙏 **Credits**

- [Cloudflare](https://cloudflare.com) for providing free tunnels
- [Lando](https://lando.dev) for the amazing development platform
- Community feedback and testing

---

**⭐ Star this repo if it helps your development workflow!**
# lando-cloudflare-tunnel
