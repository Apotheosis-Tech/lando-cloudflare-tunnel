#!/bin/bash

# Lando Cloudflare Tunnel Integration - Smart Starter
# Created by Joe with AI assistance from Claude (Anthropic)
# Battle-tested during real Facebook OAuth integration debugging
# Auto-detects Lando's port and manages tunnel configuration

set -e

# =============================================================================
# CONFIGURATION - EDIT THESE VALUES FOR YOUR PROJECT
# =============================================================================

# Your tunnel name (should be unique)
TUNNEL_NAME="your-project-dev"

# Your external domain (must be managed by Cloudflare)
EXTERNAL_DOMAIN="your-project.your-domain.com"

# Path to your Lando project (current directory by default)
PROJECT_PATH="$(pwd)"

# =============================================================================
# SCRIPT START - NO NEED TO EDIT BELOW
# =============================================================================

echo "🚀 Smart Cloudflare Tunnel Starter"
echo "=================================="
echo "Project: $TUNNEL_NAME"
echo "External URL: https://$EXTERNAL_DOMAIN"
echo "Auto-detecting local service..."
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

# Detect Lando port
echo "🔍 Detecting Lando port..."
LANDO_INFO=$(lando info --format json 2>/dev/null || echo "{}")

# Try different methods to extract port
LANDO_PORT=""

# Method 1: Look for external_connection with localhost
if [ -z "$LANDO_PORT" ]; then
    LANDO_PORT=$(echo "$LANDO_INFO" | grep -o '"external_connection":[^}]*"http://localhost:[0-9]*"' | grep -o '[0-9]*' | head -1)
fi

# Method 2: Look for any localhost port in the JSON
if [ -z "$LANDO_PORT" ]; then
    LANDO_PORT=$(echo "$LANDO_INFO" | grep -o 'localhost:[0-9]*' | grep -o '[0-9]*' | head -1)
fi

# Method 3: Manual input
if [ -z "$LANDO_PORT" ]; then
    echo "⚠️  Could not auto-detect port. Here's your Lando info:"
    lando info
    echo ""
    read -p "Please enter your Lando appserver port: " LANDO_PORT
fi

if [ -z "$LANDO_PORT" ]; then
    echo "❌ Could not determine Lando port. Exiting."
    exit 1
fi

echo "✅ Lando running on port: $LANDO_PORT"

# Test local connection
echo "🧪 Testing local connection..."
if curl -s --max-time 5 "http://localhost:$LANDO_PORT" > /dev/null; then
    echo "✅ Local connection working"
else
    echo "⚠️  Local connection test failed. Continuing anyway..."
fi

# Check if cloudflared is installed
if ! command -v cloudflared &> /dev/null; then
    echo "❌ cloudflared not found. Please install it first:"
    echo "   macOS: brew install cloudflared"
    echo "   Linux: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/"
    exit 1
fi

# Check authentication
echo "🔐 Checking Cloudflare authentication..."
if ! cloudflared tunnel list >/dev/null 2>&1; then
    echo "❌ Not authenticated with Cloudflare. Please run:"
    echo "   cloudflared tunnel login"
    exit 1
fi

echo "✅ Cloudflare authentication verified"

# Check if tunnel exists
echo "🔍 Checking tunnel status..."
TUNNEL_LIST=$(cloudflared tunnel list 2>/dev/null || echo "")

if echo "$TUNNEL_LIST" | grep -q "$TUNNEL_NAME"; then
    echo "✅ Tunnel '$TUNNEL_NAME' exists"
    TUNNEL_ID=$(echo "$TUNNEL_LIST" | grep "$TUNNEL_NAME" | awk '{print $1}')
    echo "   Tunnel ID: $TUNNEL_ID"
    
    # Check if credentials file exists
    CONFIG_DIR="$HOME/.cloudflared"
    CREDENTIALS_FILE="$CONFIG_DIR/$TUNNEL_ID.json"
    if [ ! -f "$CREDENTIALS_FILE" ]; then
        echo "❌ Credentials file missing: $CREDENTIALS_FILE"
        echo "🔧 Recreating tunnel..."
        
        # Delete broken tunnel
        cloudflared tunnel delete $TUNNEL_ID || true
        
        # Create new tunnel
        echo "🛠️  Creating new tunnel..."
        NEW_TUNNEL_OUTPUT=$(cloudflared tunnel create $TUNNEL_NAME 2>&1)
        TUNNEL_ID=$(echo "$NEW_TUNNEL_OUTPUT" | grep -o '[a-f0-9-]\{36\}' | head -1)
        
        if [ -z "$TUNNEL_ID" ]; then
            echo "❌ Failed to create tunnel. Output:"
            echo "$NEW_TUNNEL_OUTPUT"
            exit 1
        fi
        
        echo "✅ New tunnel created with ID: $TUNNEL_ID"
        
        # Configure DNS
        echo "🌐 Configuring DNS..."
        cloudflared tunnel route dns $TUNNEL_NAME $EXTERNAL_DOMAIN
        echo "✅ DNS configured for $EXTERNAL_DOMAIN"
    else
        echo "✅ Credentials file exists"
    fi
else
    echo "❌ Tunnel '$TUNNEL_NAME' not found. Creating new tunnel..."
    
    # Create new tunnel
    NEW_TUNNEL_OUTPUT=$(cloudflared tunnel create $TUNNEL_NAME 2>&1)
    TUNNEL_ID=$(echo "$NEW_TUNNEL_OUTPUT" | grep -o '[a-f0-9-]\{36\}' | head -1)
    
    if [ -z "$TUNNEL_ID" ]; then
        echo "❌ Failed to create tunnel. Output:"
        echo "$NEW_TUNNEL_OUTPUT"
        exit 1
    fi
    
    echo "✅ Tunnel created with ID: $TUNNEL_ID"
    
    # Configure DNS
    echo "🌐 Configuring DNS..."
    cloudflared tunnel route dns $TUNNEL_NAME $EXTERNAL_DOMAIN
    echo "✅ DNS configured for $EXTERNAL_DOMAIN"
fi

# Detect protocol (HTTP vs HTTPS)
echo "🔍 Detecting Lando protocol..."
LOCAL_SERVICE=""

# Test HTTP first
if curl -s -I --max-time 5 "http://localhost:$LANDO_PORT" > /dev/null 2>&1; then
    LOCAL_SERVICE="http://localhost:$LANDO_PORT"
    echo "✅ Using HTTP: $LOCAL_SERVICE"
elif curl -s -I -k --max-time 5 "https://localhost:$LANDO_PORT" > /dev/null 2>&1; then
    LOCAL_SERVICE="https://localhost:$LANDO_PORT"
    echo "✅ Using HTTPS: $LOCAL_SERVICE"
else
    echo "⚠️  Neither HTTP nor HTTPS responding. Using HTTP anyway..."
    LOCAL_SERVICE="http://localhost:$LANDO_PORT"
fi

# Create/update tunnel configuration
CONFIG_DIR="$HOME/.cloudflared"
CONFIG_FILE="$CONFIG_DIR/config.yml"

echo "📝 Updating tunnel configuration..."
mkdir -p "$CONFIG_DIR"

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
echo "   Using: $LOCAL_SERVICE -> https://$EXTERNAL_DOMAIN"

# Start tunnel
echo "🌐 Starting Cloudflare tunnel..."
echo "   External URL: https://$EXTERNAL_DOMAIN"
echo "   Local Service: $LOCAL_SERVICE"
echo ""
echo "📋 Controls:"
echo "   Stop: Press Ctrl+C"
echo "   Background: Add '&' to command"
echo "   Status: ./tunnel-status.sh"
echo ""

# Start tunnel in foreground (so you can see logs)
echo "🚀 Starting tunnel (logs will appear below)..."
cloudflared tunnel run $TUNNEL_NAME
