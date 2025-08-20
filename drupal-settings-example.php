<?php

/**
 * Drupal Settings Template for Cloudflare Tunnel Integration
 * 
 * Copy the relevant sections to your settings.local.php file.
 * Replace YOUR-DOMAIN.COM with your actual domain.
 */

/**
 * Basic Cloudflare Tunnel Configuration
 * Essential settings for any Drupal site using Cloudflare tunnels
 */

# Enable reverse proxy support for Cloudflare Tunnels
$settings['reverse_proxy'] = TRUE;

# Trust local IPs (Cloudflare tunnel acts as localhost)
$settings['reverse_proxy_addresses'] = [
  '127.0.0.1',
  '::1',
  'localhost',
];

# Trust forwarded headers from Cloudflare
$settings['reverse_proxy_trusted_headers'] = 30;

# Add your tunnel domain to trusted host patterns
$settings['trusted_host_patterns'][] = '^your-domain\.com$';

# Force external URL for all contexts
$base_url = 'https://your-domain.com';
$GLOBALS['base_url'] = 'https://your-domain.com';

/**
 * Optional: Server Variable Overrides
 * Use this if Drupal URL generation is still using internal domains
 */
if (PHP_SAPI !== 'cli') {
  $_SERVER['HTTP_HOST'] = 'your-domain.com';
  $_SERVER['SERVER_NAME'] = 'your-domain.com';
  $_SERVER['HTTPS'] = 'on';
  $_SERVER['SERVER_PORT'] = '443';
  $_SERVER['HTTP_X_FORWARDED_HOST'] = 'your-domain.com';
  $_SERVER['HTTP_X_FORWARDED_PROTO'] = 'https';
}

/**
 * Optional: OAuth/Social Media Module Configuration
 * If you're using Facebook, Google, or other OAuth modules
 */

# Example for custom Facebook module
# $config['your_facebook_module.settings']['dev_base_url'] = 'https://your-domain.com';

# Example for Social Auth modules
# $config['social_auth_facebook.settings']['app_id'] = 'your-app-id';
# $config['social_auth_facebook.settings']['app_secret'] = 'your-app-secret';

/**
 * Optional: File System Configuration
 * Ensure file URLs use the external domain
 */

# Public files base URL
$settings['file_public_base_url'] = 'https://your-domain.com/sites/default/files';

# Private files path (if using private files)
# $settings['file_private_path'] = '../private-files';

/**
 * Optional: Development-specific Settings
 * Remove these for production use
 */

# Disable caching for development
$settings['cache']['bins']['render'] = 'cache.backend.null';
$settings['cache']['bins']['page'] = 'cache.backend.null';
$settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.null';

# Environment indicator
$config['environment_indicator.indicator']['bg_color'] = '#00A329';
$config['environment_indicator.indicator']['fg_color'] = '#FFFFFF';
$config['environment_indicator.indicator']['name'] = 'Local Tunnel';

# Skip file permissions hardening for development
$settings['skip_permissions_hardening'] = TRUE;

/**
 * Usage Instructions:
 * 
 * 1. Replace 'your-domain.com' with your actual tunnel domain
 * 2. Update OAuth module configurations with your app credentials
 * 3. Add these settings to your settings.local.php (not settings.php)
 * 4. Clear Drupal cache after making changes: lando drush cr
 * 5. Test URL generation: lando drush eval "echo \Drupal::request()->getSchemeAndHttpHost();"
 */
