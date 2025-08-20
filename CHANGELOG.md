# Changelog

All notable changes to the Lando Cloudflare Tunnel Integration will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2025-08-20

### Fixed
- **CRITICAL**: Fixed 404 errors by using `localhost:PORT` instead of `*.lndo.site` in tunnel configs
- **CRITICAL**: Added HTTP/HTTPS protocol auto-detection to prevent SSL mismatch errors
- Enhanced smart-start.sh with automatic protocol detection
- Added tunnel parity testing in health-check.sh
- Updated troubleshooting guide with new error scenarios
- Improved error messages and debugging information

### Added
- Protocol detection function that tests both HTTP and HTTPS
- Tunnel response parity testing (compares local vs external responses)
- Enhanced configuration examples with localhost usage
- New troubleshooting sections for common connectivity issues

### Changed
- Default tunnel configuration now uses `localhost:PORT` instead of `*.lndo.site`
- smart-start.sh now auto-detects whether to use HTTP or HTTPS
- Improved logging and status messages throughout all scripts

## [1.0.0] - 2025-01-20

### Added
- Initial release of Lando Cloudflare Tunnel Integration package
- `smart-start.sh` - Interactive tunnel starter with auto-port detection
- `start-background.sh` - Background tunnel runner with logging
- `stop-tunnel.sh` - Clean tunnel shutdown with optional Lando stop
- `tunnel-status.sh` - Comprehensive tunnel health monitoring
- `health-check.sh` - Full connectivity and configuration testing
- `setup-domain.sh` - Interactive project configuration
- Drupal integration examples and settings templates
- Comprehensive documentation and troubleshooting guide
- MIT license for open source distribution
- Support for multiple project types (Drupal, WordPress, Laravel, Node.js)
- OAuth integration examples (Facebook, Google, etc.)
- Automatic DNS configuration through Cloudflare
- Port conflict resolution and auto-detection
- Extensive error handling and user feedback
- Example .lando.yml configurations for different frameworks

### Features
- ✅ Stable external URLs that never change
- ✅ Perfect for OAuth callback URLs
- ✅ Auto-detects Lando ports dynamically
- ✅ Works with any Lando project type
- ✅ Comprehensive health checking
- ✅ Background operation with logging
- ✅ Interactive setup and configuration
- ✅ Drupal-specific integration helpers
- ✅ Cross-platform support (macOS, Linux, WSL)
- ✅ Team-friendly shared configurations

### Requirements
- Lando 3.0+
- Cloudflare account (free tier sufficient)
- cloudflared CLI tool
- Domain managed by Cloudflare DNS
- curl (for health checks)

### Tested With
- Drupal 9.x, 10.x, 11.x
- WordPress 6.x
- Laravel 9.x, 10.x
- Node.js 16.x, 18.x, 20.x
- Custom PHP applications

## [Planned Features for Future Releases]

### [1.1.0] - Planned
- Docker Compose support
- Advanced load balancing configurations
- Multiple domain support per project
- Webhook integration for automated deployments
- CI/CD pipeline examples
- Prometheus metrics integration

### [1.2.0] - Planned  
- GUI management interface
- Visual tunnel status dashboard
- Automated SSL certificate management
- Integration with popular deployment tools
- Plugin system for custom extensions

## Migration Guide

### From ngrok
1. Remove ngrok configurations from your project
2. Run `./setup-domain.sh` to configure your Cloudflare domain
3. Update OAuth app settings with new stable URL
4. Update any hardcoded URLs in your application
5. Start tunnel with `./smart-start.sh`

### From other tunnel solutions
1. Stop existing tunnel service
2. Configure Cloudflare DNS for your domain
3. Run `./setup-domain.sh` for initial setup
4. Update application configurations
5. Test with `./health-check.sh`

## Contributing

We welcome contributions! Please see our contributing guidelines for:
- Code style and standards
- Testing requirements
- Documentation updates
- Feature request process
- Bug report templates

## Support

- 📖 Documentation: See README.md and TROUBLESHOOTING.md
- 🐛 Bug Reports: Create GitHub issues with debug info
- 💡 Feature Requests: Use GitHub discussions
- 💬 Community: Join the Lando Slack workspace

## Credits

Special thanks to:
- The Lando team for creating an amazing development platform
- Cloudflare for providing free tunnel services
- The open source community for feedback and contributions
- Early adopters who helped test and refine the package

---

**Note**: This package was created to solve real development workflow issues and is maintained by developers, for developers. We hope it saves you time and frustration! 🚀
