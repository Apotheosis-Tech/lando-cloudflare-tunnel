#!/bin/bash

# Check Cloudflare Tunnel Status and Health

# =============================================================================
# CONFIGURATION - EDIT THESE VALUES FOR YOUR PROJECT  
# =============================================================================

# Your tunnel name (should match other scripts)
TUNNEL_NAME="your-project-dev"

# Your external domain
EXTERNAL_DOMAIN="your-project.your-domain.com"

# Your Lando site URL
LANDO_SITE="yourproject.lndo.site"

# =============================================================================
# SCRIPT START - NO NEED TO EDIT BELOW
# =============================================================================

echo "📊 Cloudflare Tunnel Status"
echo "==========================="
echo "Tunnel: $TUNNEL_NAME"
echo "Domain: $EXTERNAL_DOMAIN"
echo ""

# Check if cloudflared is running
echo "🔍 Process Status:"
if pgrep -f "cloudflared tunnel run $TUNNEL_NAME" > /dev/null; then
    TUNNEL_PID=$(pgrep -f "cloudflared tunnel run $TUNNEL_NAME")
    echo "   ✅ Tunnel process running (PID: $TUNNEL_PID)"
    
    # Show process details
    echo "   📋 Process details:"
    ps -p $TUNNEL_PID -o pid,ppid,cmd --no-headers | sed 's/^/      /'
else
    echo "   ❌ Tunnel process not running"
fi

echo ""

# Check Lando status
echo "🔍 Lando Status:"
if lando info >/dev/null 2>&1; then
    echo "   ✅ Lando is running"
    
    # Get Lando port
    LANDO_INFO=$(lando info --format json 2>/dev/null || echo "{}")
    LANDO_PORT=$(echo "$LANDO_INFO" | grep -o '"external_connection":[^}]*"http://localhost:[0-9]*"' | grep -o '[0-9]*' | head -1)
    
    if [ -n "$LANDO_PORT" ]; then
        echo "   📋 Lando port: $LANDO_PORT"
    fi
else
    echo "   ❌ Lando is not running"
fi

echo ""

# Test local connectivity
echo "🔍 Local Connectivity:"
if command -v curl >/dev/null 2>&1; then
    # Test Lando site
    if curl -s --max-time 5 "http://$LANDO_SITE" >/dev/null; then
        echo "   ✅ Local Lando site accessible (http://$LANDO_SITE)"
    else
        echo "   ❌ Local Lando site not accessible (http://$LANDO_SITE)"
    fi
    
    # Test localhost port if we found it
    if [ -n "$LANDO_PORT" ]; then
        if curl -s --max-time 5 "http://localhost:$LANDO_PORT" >/dev/null; then
            echo "   ✅ Localhost port accessible (http://localhost:$LANDO_PORT)"
        else
            echo "   ❌ Localhost port not accessible (http://localhost:$LANDO_PORT)"
        fi
    fi
else
    echo "   ⚠️  curl not available for testing"
fi

echo ""

# Test external connectivity
echo "🔍 External Connectivity:"
if command -v curl >/dev/null 2>&1; then
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "https://$EXTERNAL_DOMAIN" 2>/dev/null || echo "000")
    
    if [ "$HTTP_STATUS" = "200" ]; then
        echo "   ✅ External domain accessible (https://$EXTERNAL_DOMAIN)"
        echo "   📋 HTTP Status: $HTTP_STATUS"
    elif [ "$HTTP_STATUS" = "000" ]; then
        echo "   ❌ External domain not reachable (https://$EXTERNAL_DOMAIN)"
        echo "   📋 Connection failed or timeout"
    else
        echo "   ⚠️  External domain responding (https://$EXTERNAL_DOMAIN)"
        echo "   📋 HTTP Status: $HTTP_STATUS"
    fi
    
    # Test DNS resolution
    if command -v nslookup >/dev/null 2>&1; then
        echo "   📋 DNS Resolution:"
        nslookup "$EXTERNAL_DOMAIN" | grep -E "(Address|answer)" | sed 's/^/      /' || echo "      DNS lookup failed"
    fi
else
    echo "   ⚠️  curl not available for testing"
fi

echo ""

# Show tunnel configuration
echo "🔍 Tunnel Configuration:"
CONFIG_FILE="$HOME/.cloudflared/config.yml"
if [ -f "$CONFIG_FILE" ]; then
    echo "   ✅ Config file exists: $CONFIG_FILE"
    echo "   📋 Current configuration:"
    grep -E "(tunnel:|hostname:|service:)" "$CONFIG_FILE" | sed 's/^/      /' || echo "      Could not parse config"
else
    echo "   ❌ Config file not found: $CONFIG_FILE"
fi

echo ""

# Show recent logs if available
LOG_FILE="/tmp/cloudflare-tunnel-$TUNNEL_NAME.log"
if [ -f "$LOG_FILE" ]; then
    echo "🔍 Recent Log Activity:"
    echo "   📋 Log file: $LOG_FILE"
    echo "   📋 Last 5 lines:"
    tail -5 "$LOG_FILE" | sed 's/^/      /' || echo "      Could not read logs"
else
    echo "🔍 Log file not found: $LOG_FILE"
fi

echo ""

# Summary and recommendations
echo "📋 Summary:"
if pgrep -f "cloudflared tunnel run $TUNNEL_NAME" > /dev/null && [ "$HTTP_STATUS" = "200" ]; then
    echo "   🎉 Everything looks good! Tunnel is running and accessible."
elif pgrep -f "cloudflared tunnel run $TUNNEL_NAME" > /dev/null; then
    echo "   ⚠️  Tunnel is running but external domain may not be accessible."
    echo "   💡 Check DNS settings and tunnel configuration."
else
    echo "   ❌ Tunnel is not running."
    echo "   💡 Run ./smart-start.sh or ./start-background.sh to start."
fi

echo ""
echo "📋 Useful Commands:"
echo "   Start (interactive): ./smart-start.sh"
echo "   Start (background): ./start-background.sh"
echo "   Stop: ./stop-tunnel.sh"
echo "   View logs: tail -f $LOG_FILE"
echo "   Test external: curl -I https://$EXTERNAL_DOMAIN"
