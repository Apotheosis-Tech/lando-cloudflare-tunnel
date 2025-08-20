# Lando Cloudflare Tunnel Integration

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A complete solution for integrating **Cloudflare Tunnels** with **Lando** development environments. Get stable, permanent external URLs for your local development - no more random ngrok URLs that break your OAuth callbacks!

> **⚠️ Maintenance Notice**: This project is minimally maintained. It's production-ready and battle-tested, but expect infrequent updates. Community contributions are welcome!

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

**Option 1: Quick Install (Recommended)**
```bash
# Clone and install in one command
git clone https://github.com/Apotheosis-Tech/lando-cloudflare-tunnel.git
cd lando-cloudflare-tunnel
chmod +x install.sh  # Make installer executable
./install.sh /path/to/your/lando/project
```

**Option 2: Manual Install**
```bash
# Clone the repository
git clone https://github.com/Apotheosis-Tech/lando-cloudflare-tunnel.git

# Copy scripts to your Lando project
cp scripts/* /path/to/your/lando/project/tunnel/
chmod +x /path/to/your/lando/project/tunnel/*.sh

# Copy configuration examples
cp examples/* /path/to/your/lando/project/tunnel/
```

## 📁 **What's Included**

```
lando-cloudflare-tunnel/
├── scripts/           # Executable scripts
│   ├── smart-start.sh     # Auto-detects port and starts tunnel
│   ├── start-background.sh # Background tunnel with logging
│   ├── stop-tunnel.sh     # Stop tunnel and optionally Lando
│   ├── tunnel-status.sh   # Check tunnel health
│   ├── health-check.sh    # Comprehensive connectivity testing
│   └── setup-domain.sh    # Interactive domain configuration
├── examples/          # Configuration templates
│   ├── config-example.yml
│   ├── drupal-settings-example.php
│   ├── project-launcher   # Comprehensive project launcher template
│   └── README.md          # Examples documentation
├── docs/              # Documentation
│   ├── TROUBLESHOOTING.md
│   ├── CONTRIBUTING.md
│   └── LANDO_EXAMPLES.md
├── tunnel             # Global tunnel launcher
└── install.sh         # One-command installer
```

## 📋 **Commands**

### Option 1: Individual Tunnel Commands

After installation, navigate to the tunnel directory in your project:

```bash
cd tunnel/  # or wherever you installed the scripts
```

| Command | Purpose |
|---------|----------|
| `./smart-start.sh` | Start tunnel (interactive, shows logs) |
| `./start-background.sh` | Start tunnel in background |
| `./stop-tunnel.sh` | Stop tunnel |
| `./tunnel-status.sh` | Check if tunnel is running |
| `./health-check.sh` | Test connectivity |
| `./setup-domain.sh` | Configure domain settings |

### Option 2: Global Tunnel Launcher

Run tunnel commands from anywhere in your project using the global launcher:

```bash
tunnel           # Start tunnel (same as tunnel start)
tunnel bg        # Start in background  
tunnel status    # Check status
tunnel stop      # Stop tunnel
tunnel help      # Show help
```

### Option 3: Complete Project Launcher (Recommended)

For the ultimate convenience, copy the project launcher template to your project root:

```bash
# Copy the template
cp examples/project-launcher /path/to/your/project/dev
chmod +x dev

# Now use one script for everything:
./dev full-start              # Start Lando + Tunnel
./dev tunnel-status          # Check tunnel status  
./dev drush cr               # Clear cache (Drupal)
./dev db-backup              # Database backup
./dev status                 # Complete project status
```

The project launcher provides a single command interface for all development operations, making your workflow much more efficient. See `examples/README.md` for full documentation.

### First Time Setup

1. **Install prerequisites:**
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

3. **Configure your domain:**
   ```bash
   ./setup-domain.sh  # Interactive configuration
   # OR edit smart-start.sh manually
   ```

4. **Start your tunnel:**
   ```bash
   ./smart-start.sh
   ```

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

Perfect for OAuth applications! The package provides stable callback URLs for any OAuth provider:

```bash
# Generic OAuth callback patterns that work with any provider:
https://your-project.your-domain.com/oauth/callback
https://your-project.your-domain.com/auth/{provider}/callback
https://your-project.your-domain.com/login/{provider}/callback
https://your-project.your-domain.com/api/auth/{provider}/callback

# Real-world examples for popular providers:
https://your-project.your-domain.com/auth/facebook/callback    # Facebook OAuth
https://your-project.your-domain.com/auth/google/callback      # Google OAuth  
https://your-project.your-domain.com/auth/github/callback      # GitHub OAuth
https://your-project.your-domain.com/auth/twitter/callback     # Twitter OAuth
https://your-project.your-domain.com/oauth/discord/callback    # Discord OAuth
https://your-project.your-domain.com/login/linkedin/callback   # LinkedIn OAuth
```

**Why This Matters:**
- ✅ **No More Broken Development** - Callback URLs never change
- ✅ **Team Collaboration** - Everyone uses the same callback URLs
- ✅ **Production Parity** - Same URL structure as production
- ✅ **Multi-Provider Support** - Works with any OAuth provider

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
    cd tunnel/
    ./start-background.sh
    ./health-check.sh
```

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

For comprehensive troubleshooting, see: `docs/TROUBLESHOOTING.md`

## 🔒 **Security Notes**

- Tunnels expose your local development to the internet
- Use strong authentication in your applications
- Consider IP restrictions for sensitive projects
- Don't commit tunnel credentials to version control

## 🤝 **Contributing**

Contributions welcome! Please see `docs/CONTRIBUTING.md` for:

1. Code style and standards
2. Testing requirements
3. Documentation updates
4. Feature request process

## 📄 **License**

MIT License - see LICENSE file for details.

## 🙏 **Credits**

- **Created by**: [Joe Stramel](https://github.com/Apotheosis-Tech) with AI assistance from Claude (Anthropic)
- **Battle-tested during**: Real Facebook OAuth integration debugging
- **Key breakthrough**: Discovering localhost:PORT vs *.lndo.site reliability issues
- [Cloudflare](https://cloudflare.com) for providing free tunnels
- [Lando](https://lando.dev) for the amazing development platform
- Community feedback and testing

**Development Note**: This package was developed collaboratively between human expertise and AI assistance, combining real-world debugging experience with comprehensive automation.

---

**⭐ Star this repo if it helps your development workflow!**
