#!/bin/bash

# Stop Cloudflare Tunnel and optionally Lando

# =============================================================================
# CONFIGURATION - EDIT THESE VALUES FOR YOUR PROJECT
# =============================================================================

# Your tunnel name (should match other scripts)
TUNNEL_NAME="your-project-dev"

# =============================================================================
# SCRIPT START - NO NEED TO EDIT BELOW
# =============================================================================

echo "🛑 Stopping Development Environment"
echo "=================================="
echo "Tunnel: $TUNNEL_NAME"
echo ""

# Stop Cloudflare tunnel
if pgrep -f "cloudflared tunnel run $TUNNEL_NAME" > /dev/null; then
    echo "🌐 Stopping Cloudflare tunnel..."
    pkill -f "cloudflared tunnel run $TUNNEL_NAME"
    sleep 2
    
    # Verify it stopped
    if pgrep -f "cloudflared tunnel run $TUNNEL_NAME" > /dev/null; then
        echo "⚠️  Tunnel still running. Force killing..."
        pkill -9 -f "cloudflared tunnel run $TUNNEL_NAME"
    fi
    
    echo "✅ Tunnel stopped"
else
    echo "ℹ️  No tunnel running"
fi

# Ask about stopping Lando
echo ""
read -p "Stop Lando as well? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "📦 Stopping Lando..."
    lando stop
    echo "✅ Lando stopped"
fi

echo ""
echo "🎉 Development environment stopped!"
echo ""
echo "📋 To restart:"
echo "   Interactive: ./smart-start.sh"
echo "   Background: ./start-background.sh"
