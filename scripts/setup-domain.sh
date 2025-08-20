#!/bin/bash

# Interactive setup script for configuring domain settings
# Helps users customize the tunnel for their specific project

echo "🔧 Lando Cloudflare Tunnel Setup"
echo "================================"
echo ""
echo "This script will help you configure the tunnel for your project."
echo ""

# Get current directory name as default project name
CURRENT_DIR=$(basename "$(pwd)")
DEFAULT_TUNNEL_NAME="$CURRENT_DIR-dev"

# Collect configuration
echo "📝 Project Configuration:"
echo ""

read -p "Project/Tunnel name [$DEFAULT_TUNNEL_NAME]: " TUNNEL_NAME
TUNNEL_NAME=${TUNNEL_NAME:-$DEFAULT_TUNNEL_NAME}

echo ""
read -p "External domain (e.g., myproject.mydomain.com): " EXTERNAL_DOMAIN

if [ -z "$EXTERNAL_DOMAIN" ]; then
    echo "❌ External domain is required. Exiting."
    exit 1
fi

echo ""
read -p "Lando site URL [$CURRENT_DIR.lndo.site]: " LANDO_SITE
LANDO_SITE=${LANDO_SITE:-$CURRENT_DIR.lndo.site}

echo ""
echo "📋 Configuration Summary:"
echo "   Tunnel name: $TUNNEL_NAME"
echo "   External domain: $EXTERNAL_DOMAIN"
echo "   Lando site: $LANDO_SITE"
echo "   External URL: https://$EXTERNAL_DOMAIN"
echo ""

read -p "Proceed with configuration? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 0
fi

echo ""
echo "🔧 Updating configuration files..."

# Update all shell scripts with the new configuration
for script in smart-start.sh start-background.sh stop-tunnel.sh tunnel-status.sh; do
    if [ -f "$script" ]; then
        echo "   📝 Updating $script..."
        
        # Update tunnel name
        sed -i.bak "s/TUNNEL_NAME=\"your-project-dev\"/TUNNEL_NAME=\"$TUNNEL_NAME\"/g" "$script"
        
        # Update external domain
        sed -i.bak "s/EXTERNAL_DOMAIN=\"your-project.your-domain.com\"/EXTERNAL_DOMAIN=\"$EXTERNAL_DOMAIN\"/g" "$script"
        
        # Update Lando site
        sed -i.bak "s/LANDO_SITE=\"yourproject.lndo.site\"/LANDO_SITE=\"$LANDO_SITE\"/g" "$script"
        
        # Remove backup file
        rm -f "$script.bak"
        
        echo "   ✅ $script updated"
    else
        echo "   ⚠️  $script not found"
    fi
done

echo ""
echo "📄 Creating Drupal settings template..."

# Create Drupal settings template
cat > "drupal-settings-template.php" << 'EOF'
<?php

/**
 * Cloudflare Tunnel Configuration for Drupal
 * Add this to your settings.local.php file
 */

# Enable reverse proxy support for Cloudflare Tunnels
$settings['reverse_proxy'] = TRUE;

# Trust local IPs (Cloudflare tunnel acts as localhost)
$settings['reverse_proxy_addresses'] = [
  '127.0.0.1',
  '::1',
  'localhost',
];

# Trust forwarded headers
$settings['reverse_proxy_trusted_headers'] = 30;

# Add your tunnel domain to trusted host patterns
$settings['trusted_host_patterns'][] = '^DOMAIN_PATTERN$';

# Force external URL for all contexts
$base_url = 'https://EXTERNAL_DOMAIN';
$GLOBALS['base_url'] = 'https://EXTERNAL_DOMAIN';

# Override server variables to match external domain (non-CLI only)
if (PHP_SAPI !== 'cli') {
  $_SERVER['HTTP_HOST'] = 'EXTERNAL_DOMAIN';
  $_SERVER['SERVER_NAME'] = 'EXTERNAL_DOMAIN';
  $_SERVER['HTTPS'] = 'on';
  $_SERVER['SERVER_PORT'] = '443';
  $_SERVER['HTTP_X_FORWARDED_HOST'] = 'EXTERNAL_DOMAIN';
  $_SERVER['HTTP_X_FORWARDED_PROTO'] = 'https';
}
EOF

# Replace placeholders in the template
DOMAIN_PATTERN=$(echo "$EXTERNAL_DOMAIN" | sed 's/\./\\./g')
sed -i.bak "s/EXTERNAL_DOMAIN/$EXTERNAL_DOMAIN/g" "drupal-settings-template.php"
sed -i.bak "s/DOMAIN_PATTERN/$DOMAIN_PATTERN/g" "drupal-settings-template.php"
rm -f "drupal-settings-template.php.bak"

echo "   ✅ Created drupal-settings-template.php"

echo ""
echo "🔑 Cloudflare Setup Requirements:"
echo "   1. Make sure you have a Cloudflare account"
echo "   2. Your domain ($EXTERNAL_DOMAIN) must be managed by Cloudflare"
echo "   3. Install cloudflared: brew install cloudflared (macOS)"
echo "   4. Authenticate: cloudflared tunnel login"

echo ""
echo "📋 Next Steps:"
echo "   1. Run: chmod +x *.sh"
echo "   2. Start tunnel: ./smart-start.sh"
echo "   3. For Drupal projects: Add drupal-settings-template.php content to your settings.local.php"
echo "   4. Check status: ./tunnel-status.sh"

echo ""
echo "🎉 Configuration complete!"
echo "   Your tunnel will be available at: https://$EXTERNAL_DOMAIN"
echo "   Local development at: http://$LANDO_SITE"
