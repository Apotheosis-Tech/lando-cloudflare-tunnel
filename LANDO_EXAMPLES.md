# Example .lando.yml configurations for different project types

## Basic Drupal Project
```yaml
name: myproject
recipe: drupal10
config:
  webroot: web
  php: '8.2'
services:
  appserver:
    scanner: false
  database:
    type: mysql:8.0
tooling:
  tunnel:
    service: appserver
    description: Start Cloudflare tunnel
    cmd: ./smart-start.sh
  tunnel-bg:
    service: appserver  
    description: Start tunnel in background
    cmd: ./start-background.sh
  tunnel-stop:
    service: appserver
    description: Stop tunnel
    cmd: ./stop-tunnel.sh
```

## WordPress Project
```yaml
name: mywordpress
recipe: wordpress
config:
  php: '8.1'
  webroot: .
services:
  appserver:
    scanner: false
tooling:
  tunnel:
    service: appserver
    description: Start Cloudflare tunnel
    cmd: ./smart-start.sh
```

## Laravel Project  
```yaml
name: mylaravel
recipe: laravel
config:
  php: '8.2'
services:
  appserver:
    scanner: false
    build:
      - composer install
tooling:
  tunnel:
    service: appserver
    description: Start Cloudflare tunnel
    cmd: ./smart-start.sh
  artisan:
    service: appserver
    cmd: php artisan
```

## Node.js/Express Project
```yaml
name: mynode
recipe: node
config:
  nodejs: '18'
services:
  appserver:
    scanner: false
    port: 3000
tooling:
  tunnel:
    service: appserver
    description: Start Cloudflare tunnel
    cmd: ./smart-start.sh
  npm:
    service: appserver
  node:
    service: appserver
```

## Custom PHP Project
```yaml
name: mycustom
recipe: lamp
config:
  php: '8.2'
  webroot: public
services:
  appserver:
    scanner: false
tooling:
  tunnel:
    service: appserver
    description: Start Cloudflare tunnel
    cmd: ./smart-start.sh
```

## Tips for Integration

1. **Add tunnel tooling commands** to your .lando.yml for easy access
2. **Use consistent naming** - tunnel name should match your Lando app name
3. **Set scanner: false** to prevent port conflicts
4. **Document your external domain** in your project README
