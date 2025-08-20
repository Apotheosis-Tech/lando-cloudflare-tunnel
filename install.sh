#!/bin/bash

# Lando Cloudflare Tunnel Integration - Quick Installer
# Copies all necessary scripts to your Lando project

set -e

# Check if script is executable
if [ ! -x "$0" ]; then
    echo "⚠️  Script not executable. Fixing permissions..."
    chmod +x "$0"
    echo "✅ Permissions fixed. Please run again: $0 $@"
    exit 1
fi

echo "🚀 Lando Cloudflare Tunnel Integration Installer"
echo "================================================"

# Default to current directory if no argument provided
PROJECT_DIR="${1:-$(pwd)}"

# Validate project directory
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ Directory not found: $PROJECT_DIR"
    exit 1
fi

# Check if this looks like a Lando project
if [ ! -f "$PROJECT_DIR/.lando.yml" ]; then
    echo "⚠️  Warning: No .lando.yml found in $PROJECT_DIR"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 1
    fi
fi

echo "📁 Installing to: $PROJECT_DIR"
echo ""

# Create tunnel directory in project
TUNNEL_DIR="$PROJECT_DIR/tunnel"
mkdir -p "$TUNNEL_DIR"

# Copy scripts
echo "📦 Copying scripts..."
SCRIPT_DIR="$(dirname "$0")/scripts"

if [ ! -d "$SCRIPT_DIR" ]; then
    echo "❌ Scripts directory not found. Are you running this from the repo root?"
    exit 1
fi

cp "$SCRIPT_DIR"/*.sh "$TUNNEL_DIR/"
chmod +x "$TUNNEL_DIR"/*.sh

echo "✅ Scripts copied to $TUNNEL_DIR/"

# Copy global launcher
echo "📦 Copying global tunnel launcher..."
if [ -f "$(dirname "$0")/tunnel" ]; then
    cp "$(dirname "$0")/tunnel" "$TUNNEL_DIR/"
    chmod +x "$TUNNEL_DIR/tunnel"
    echo "✅ Global launcher copied"
fi

# Copy examples
echo "📋 Copying configuration examples..."
EXAMPLES_DIR="$(dirname "$0")/examples"
if [ -d "$EXAMPLES_DIR" ]; then
    cp "$EXAMPLES_DIR"/* "$TUNNEL_DIR/"
    echo "✅ Examples copied"
fi

# Copy key documentation
echo "📖 Copying documentation..."
if [ -f "$(dirname "$0")/docs/TROUBLESHOOTING.md" ]; then
    cp "$(dirname "$0")/docs/TROUBLESHOOTING.md" "$TUNNEL_DIR/"
fi

echo ""
echo "🎉 Installation Complete!"
echo "========================"
echo ""
echo "📂 Files installed in: $TUNNEL_DIR/"
echo ""
echo "🚀 Next Steps:"
echo "  1. cd $TUNNEL_DIR"
echo "  2. Edit smart-start.sh to configure your domain"
echo "  3. Run: ./smart-start.sh"
echo ""
echo "📋 Available Commands:"
echo "  ./smart-start.sh        - Start tunnel (interactive)"
echo "  ./start-background.sh   - Start tunnel in background"
echo "  ./stop-tunnel.sh        - Stop tunnel"
echo "  ./tunnel-status.sh      - Check tunnel status"
echo "  ./health-check.sh       - Test connectivity"
echo "  ./setup-domain.sh       - Configure domain settings"
echo ""
echo "🎆 Global Launcher (run from anywhere in project):"
echo "  ./tunnel                 - Smart launcher (same as smart-start)"
echo "  ./tunnel bg              - Start in background"
echo "  ./tunnel status          - Check status"
echo "  ./tunnel stop            - Stop tunnel"
echo ""
echo "🔧 Project Launcher (Recommended):"
echo "  cp tunnel/project-launcher ./dev && chmod +x dev"
echo "  ./dev full-start         - Start Lando + Tunnel"
echo "  ./dev tunnel-status      - Check tunnel status"
echo "  ./dev drush cr           - Framework commands"
echo "  ./dev db-backup          - Database operations"
echo "  ./dev status             - Complete project status"
echo ""
echo "📖 Documentation:"
echo "  TROUBLESHOOTING.md      - Common issues and solutions"
echo "  config-example.yml      - Tunnel configuration template"
echo "  drupal-settings-example.php - Drupal integration example"
echo "  project-launcher        - Complete project management template"
echo ""
echo "🆘 Need Help?"
echo "  Check TROUBLESHOOTING.md or visit the GitHub repo"
echo ""
echo "Happy developing! 🎯"
