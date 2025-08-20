# Examples

This directory contains example files and templates to help you integrate the lando-cloudflare-tunnel package into your projects.

## project-launcher

A comprehensive project launcher template that you can copy to your project root directory. This script provides a single command interface for all your development operations.

### Installation

1. Copy the `project-launcher` file to your project root directory:
   ```bash
   cp examples/project-launcher /path/to/your/project/dev
   ```

2. Make it executable:
   ```bash
   chmod +x dev
   ```

3. Customize it for your specific framework and needs (see comments in the file)

### Usage

```bash
# Quick start everything
./dev full-start              # Start Lando + Tunnel

# Individual operations  
./dev start                   # Start Lando only
./dev tunnel                  # Start tunnel (foreground)
./dev tunnel-bg              # Start tunnel (background)
./dev tunnel-status          # Check tunnel status
./dev cache-clear            # Clear cache (framework-specific)
./dev db-backup              # Create database backup
./dev status                 # Show complete project status

# Development commands
./dev drush cr               # Drupal: Clear cache
./dev artisan migrate        # Laravel: Run migrations
./dev wp cache flush         # WordPress: Clear cache
./dev composer install       # Composer commands
./dev npm install            # NPM commands
```

### Framework Support

The project launcher includes automatic detection and commands for:

- **Drupal**: `drush` commands, configuration management
- **Laravel**: `artisan` commands, migrations
- **WordPress**: `wp-cli` commands
- **Symfony**: Console commands
- **General**: Composer, NPM, database operations

### Customization

Edit the script to:
- Add your own custom commands
- Modify framework-specific operations
- Add project-specific workflows
- Change command names and aliases

### Benefits

- **Single entry point** for all project operations
- **Smart Lando management** - automatically starts when needed
- **Framework-agnostic** - works with any PHP framework
- **Colored output** for better visibility
- **Error handling** with helpful messages
- **Extensible** - easy to add custom commands

This launcher script solves the common problem of having to remember and type multiple commands like:
```bash
# Instead of this:
lando start
cd tunnel
./smart-start.sh

# You can do this:
./dev full-start
```
