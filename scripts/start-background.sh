#!/bin/bash

# Background Cloudflare Tunnel Starter for Lando Development
# Runs the tunnel in background with logging

set -e

# =============================================================================
# CONFIGURATION - EDIT THESE VALUES FOR YOUR PROJECT
# =============================================================================

# Your tunnel name (should match smart-start.sh)
TUNNEL_NAME="your-project-dev"

# Your external domain (must be managed by Cloudflare)
EXTERNAL_DOMAIN="your-project.your-domain.com"

# Your Lando site URL (typically yourproject.lndo.site)
LANDO_SITE="yourproject.lndo.site"

# Path to your Lando project (current directory by default)
PROJECT_PATH="$(pwd)"

# Log file location
LOG_FILE="/tmp/cloudflare-tunnel-$TUNNEL_NAME.log"

# =============================================================================
# SCRIPT START - NO NEED TO EDIT BELOW
# =============================================================================

echo "🚀 Background Cloudflare Tunnel Starter"
echo "======================================="
echo "Project: $TUNNEL_NAME"
echo "External URL: https://$EXTERNAL_DOMAIN"
echo ""

# Change to project directory
cd "$PROJECT_PATH"

# Start Lando if not running
echo "📦 Starting Lando..."
if ! lando info >/dev/null 2>&1; then
    lando start
else
    echo "✅ Lando already running"
fi

# Wait a moment for Lando to fully start
sleep 3

# Detect Lando port (same logic as smart-start.sh)
echo "🔍 Detecting Lando port..."
LANDO_INFO=$(lando info --format json 2>/dev/null || echo "{}")

LANDO_PORT=""
if [ -z "$LANDO_PORT" ]; then
    LANDO_PORT=$(echo "$LANDO_INFO" | grep -o '"external_connection":[^}]*"http://localhost:[0-9]*"' | grep -o '[0-9]*' | head -1)
fi

if [ -z "$LANDO_PORT" ]; then
    LANDO_PORT=$(echo "$LANDO_INFO" | grep -o 'localhost:[0-9]*' | grep -o '[0-9]*' | head -1)
fi

if [ -z "$LANDO_PORT" ]; then
    echo "⚠️  Could not auto-detect port. Here's your Lando info:"
    lando info
    echo ""
    read -p "Please enter your Lando appserver port: " LANDO_PORT
fi

echo "✅ Lando running on port: $LANDO_PORT"

# Check tunnel status
echo "🔍 Checking tunnel configuration..."
TUNNEL_LIST=$(cloudflared tunnel list 2>/dev/null || echo "")

if echo "$TUNNEL_LIST" | grep -q "$TUNNEL_NAME"; then
    TUNNEL_ID=$(echo "$TUNNEL_LIST" | grep "$TUNNEL_NAME" | awk '{print $1}')
    echo "✅ Tunnel exists with ID: $TUNNEL_ID"
else
    echo "❌ Tunnel '$TUNNEL_NAME' not found. Please run ./smart-start.sh first to set up the tunnel."
    exit 1
fi

# Detect protocol and service URL
echo "🔍 Detecting service protocol..."
LOCAL_SERVICE=""

# Test both localhost port and Lando site approaches
if [ -n "$LANDO_PORT" ]; then
    # Test HTTPS first (Lando often uses HTTPS on higher ports)
    HTTPS_TEST=$(curl -s -I -k --max-time 5 "https://localhost:$LANDO_PORT" 2>&1 || true)
    HTTP_TEST=$(curl -s -I --max-time 5 "http://localhost:$LANDO_PORT" 2>&1 || true)
    
    # Check if HTTPS returns a proper HTTP response (not SSL error)
    if echo "$HTTPS_TEST" | grep -q "HTTP/"; then
        LOCAL_SERVICE="https://localhost:$LANDO_PORT"
        echo "✅ Using HTTPS localhost: $LOCAL_SERVICE"
    # Check if HTTP returns a proper response (and not SSL error)
    elif echo "$HTTP_TEST" | grep -q "HTTP/" && ! echo "$HTTP_TEST" | grep -q "SSL"; then
        LOCAL_SERVICE="http://localhost:$LANDO_PORT"
        echo "✅ Using HTTP localhost: $LOCAL_SERVICE"
    # Default to HTTPS for higher ports (typical Lando pattern)
    elif [ "$LANDO_PORT" -gt 54570 ]; then
        LOCAL_SERVICE="https://localhost:$LANDO_PORT"
        echo "✅ Defaulting to HTTPS for high port: $LOCAL_SERVICE"
    else
        LOCAL_SERVICE="http://localhost:$LANDO_PORT"
        echo "✅ Defaulting to HTTP for low port: $LOCAL_SERVICE"
    fi
else
    # Fallback to Lando site URL if port detection failed
    # Test HTTPS first for Lando site
    HTTPS_SITE_TEST=$(curl -s -I -k --max-time 5 "https://$LANDO_SITE" 2>&1 || true)
    HTTP_SITE_TEST=$(curl -s -I --max-time 5 "http://$LANDO_SITE" 2>&1 || true)
    
    if echo "$HTTPS_SITE_TEST" | grep -q "HTTP/"; then
        LOCAL_SERVICE="https://$LANDO_SITE"
        echo "✅ Using HTTPS Lando site: $LOCAL_SERVICE"
    elif echo "$HTTP_SITE_TEST" | grep -q "HTTP/"; then
        LOCAL_SERVICE="http://$LANDO_SITE"
        echo "✅ Using HTTP Lando site: $LOCAL_SERVICE"
    else
        # Default fallback
        LOCAL_SERVICE="http://$LANDO_SITE"
        echo "⚠️  Protocol detection failed, using HTTP fallback: $LOCAL_SERVICE"
    fi
fi

# Update tunnel configuration
CONFIG_DIR="$HOME/.cloudflared"
CONFIG_FILE="$CONFIG_DIR/config.yml"

echo "📝 Updating tunnel configuration..."
cat > "$CONFIG_FILE" << EOF
tunnel: $TUNNEL_ID
credentials-file: $CONFIG_DIR/$TUNNEL_ID.json

ingress:
  - hostname: $EXTERNAL_DOMAIN
    service: $LOCAL_SERVICE
    originRequest:
      noTLSVerify: true
  - service: http_status:404
EOF

echo "✅ Configuration updated"

# Check if tunnel is already running
if pgrep -f "cloudflared tunnel run $TUNNEL_NAME" > /dev/null; then
    echo "⚠️  Tunnel already running. Stopping old instance..."
    pkill -f "cloudflared tunnel run $TUNNEL_NAME"
    sleep 2
fi

# Start tunnel in background
echo "🌐 Starting Cloudflare tunnel in background..."
echo "   External URL: https://$EXTERNAL_DOMAIN"
echo "   Log file: $LOG_FILE"

# Start tunnel in background with logging
nohup cloudflared tunnel run $TUNNEL_NAME > "$LOG_FILE" 2>&1 &
TUNNEL_PID=$!

# Wait a moment and check if it started successfully
sleep 3

if ps -p $TUNNEL_PID > /dev/null; then
    echo "✅ Tunnel started successfully!"
    echo "   PID: $TUNNEL_PID"
    echo ""
    echo "📋 Useful commands:"
    echo "   View logs: tail -f $LOG_FILE"
    echo "   Stop tunnel: ./stop-tunnel.sh"
    echo "   Check status: ./tunnel-status.sh"
    echo "   Test tunnel: curl -I https://$EXTERNAL_DOMAIN"
    echo ""
    echo "🎉 Development environment ready!"
    echo "   Local Service: $LOCAL_SERVICE"
    echo "   External: https://$EXTERNAL_DOMAIN"
else
    echo "❌ Tunnel failed to start. Check logs:"
    cat "$LOG_FILE"
    exit 1
fi
