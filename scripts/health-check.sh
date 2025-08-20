#!/bin/bash

# Health check script for tunnel and local connectivity
# Comprehensive testing of the development environment

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

echo "🏥 Cloudflare Tunnel Health Check"
echo "================================="
echo "Testing: $EXTERNAL_DOMAIN"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

# Helper function for test results
test_result() {
    local test_name="$1"
    local result="$2"
    local details="$3"
    
    if [ "$result" = "pass" ]; then
        echo -e "   ${GREEN}✅ $test_name${NC}"
        if [ -n "$details" ]; then
            echo "      $details"
        fi
        TESTS_PASSED=$((TESTS_PASSED + 1))
    elif [ "$result" = "warn" ]; then
        echo -e "   ${YELLOW}⚠️  $test_name${NC}"
        if [ -n "$details" ]; then
            echo "      $details"
        fi
    else
        echo -e "   ${RED}❌ $test_name${NC}"
        if [ -n "$details" ]; then
            echo "      $details"
        fi
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test 1: Check if cloudflared is installed
echo "🔍 Testing Prerequisites:"
if command -v cloudflared >/dev/null 2>&1; then
    VERSION=$(cloudflared --version 2>/dev/null | head -1)
    test_result "cloudflared installed" "pass" "$VERSION"
else
    test_result "cloudflared installed" "fail" "Install with: brew install cloudflared"
fi

# Test 2: Check Cloudflare authentication
if cloudflared tunnel list >/dev/null 2>&1; then
    test_result "Cloudflare authenticated" "pass"
else
    test_result "Cloudflare authenticated" "fail" "Run: cloudflared tunnel login"
fi

# Test 3: Check if Lando is installed and running
if command -v lando >/dev/null 2>&1; then
    test_result "Lando installed" "pass"
    
    if lando info >/dev/null 2>&1; then
        test_result "Lando running" "pass"
    else
        test_result "Lando running" "fail" "Run: lando start"
    fi
else
    test_result "Lando installed" "fail" "Install from: https://lando.dev"
fi

echo ""

# Test 4: Check tunnel process
echo "🔍 Testing Tunnel Status:"
if pgrep -f "cloudflared tunnel run $TUNNEL_NAME" >/dev/null; then
    PID=$(pgrep -f "cloudflared tunnel run $TUNNEL_NAME")
    test_result "Tunnel process running" "pass" "PID: $PID"
else
    test_result "Tunnel process running" "fail" "Start with: ./smart-start.sh"
fi

# Test 5: Check tunnel configuration
CONFIG_FILE="$HOME/.cloudflared/config.yml"
if [ -f "$CONFIG_FILE" ]; then
    test_result "Tunnel config exists" "pass" "$CONFIG_FILE"
    
    if grep -q "$EXTERNAL_DOMAIN" "$CONFIG_FILE"; then
        test_result "Config contains domain" "pass"
    else
        test_result "Config contains domain" "fail" "Domain not found in config"
    fi
else
    test_result "Tunnel config exists" "fail" "Config file missing"
fi

echo ""

# Test 6: Local connectivity tests
echo "🔍 Testing Local Connectivity:"

# Test Lando site connectivity
if command -v curl >/dev/null 2>&1; then
    if curl -s --max-time 5 "http://$LANDO_SITE" >/dev/null; then
        test_result "Lando site accessible" "pass" "http://$LANDO_SITE"
    else
        test_result "Lando site accessible" "fail" "Cannot reach http://$LANDO_SITE"
    fi
    
    # Try to detect Lando port
    if lando info >/dev/null 2>&1; then
        LANDO_INFO=$(lando info --format json 2>/dev/null || echo "{}")
        LANDO_PORT=$(echo "$LANDO_INFO" | grep -o '"external_connection":[^}]*"http://localhost:[0-9]*"' | grep -o '[0-9]*' | head -1)
        
        if [ -n "$LANDO_PORT" ]; then
            if curl -s --max-time 5 "http://localhost:$LANDO_PORT" >/dev/null; then
                test_result "Localhost port accessible" "pass" "Port: $LANDO_PORT"
            else
                test_result "Localhost port accessible" "fail" "Port $LANDO_PORT not responding"
            fi
        else
            test_result "Lando port detection" "warn" "Could not detect port"
        fi
    fi
else
    test_result "curl available" "fail" "curl required for testing"
fi

echo ""

# Test 7: External connectivity tests
echo "🔍 Testing External Connectivity:"

if command -v curl >/dev/null 2>&1; then
    # Test HTTPS connectivity
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "https://$EXTERNAL_DOMAIN" 2>/dev/null || echo "000")
    
    if [ "$HTTP_STATUS" = "200" ]; then
        test_result "HTTPS connectivity" "pass" "Status: $HTTP_STATUS"
    elif [ "$HTTP_STATUS" = "000" ]; then
        test_result "HTTPS connectivity" "fail" "Connection failed or timeout"
    else
        test_result "HTTPS connectivity" "warn" "Status: $HTTP_STATUS (not 200)"
    fi
    
    # Test tunnel parity (compare local vs external responses)
    if [ -n "$LANDO_PORT" ] && [ "$HTTP_STATUS" != "000" ]; then
        LOCAL_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "http://localhost:$LANDO_PORT" 2>/dev/null || echo "000")
        
        if [ "$LOCAL_STATUS" = "$HTTP_STATUS" ]; then
            test_result "Tunnel parity" "pass" "Local and external responses match ($HTTP_STATUS)"
        elif [ "$LOCAL_STATUS" != "000" ] && [ "$HTTP_STATUS" != "000" ]; then
            test_result "Tunnel parity" "warn" "Different responses: Local=$LOCAL_STATUS, External=$HTTP_STATUS"
        else
            test_result "Tunnel parity" "fail" "Cannot compare responses"
        fi
    fi
    
    # Test response time
    RESPONSE_TIME=$(curl -s -o /dev/null -w "%{time_total}" --max-time 10 "https://$EXTERNAL_DOMAIN" 2>/dev/null || echo "0")
    if [ "$RESPONSE_TIME" != "0" ]; then
        # Convert to milliseconds
        RESPONSE_MS=$(echo "$RESPONSE_TIME * 1000" | bc 2>/dev/null || echo "unknown")
        test_result "Response time" "pass" "${RESPONSE_MS}ms"
    fi
    
    # Test SSL certificate
    if command -v openssl >/dev/null 2>&1; then
        SSL_CHECK=$(echo | openssl s_client -servername "$EXTERNAL_DOMAIN" -connect "$EXTERNAL_DOMAIN:443" 2>/dev/null | openssl x509 -noout -issuer 2>/dev/null)
        if echo "$SSL_CHECK" | grep -q "Cloudflare"; then
            test_result "SSL certificate" "pass" "Cloudflare certificate detected"
        elif [ -n "$SSL_CHECK" ]; then
            test_result "SSL certificate" "pass" "Valid certificate"
        else
            test_result "SSL certificate" "warn" "Could not verify certificate"
        fi
    fi
fi

# Test 8: DNS resolution
echo ""
echo "🔍 Testing DNS Resolution:"

if command -v nslookup >/dev/null 2>&1; then
    DNS_RESULT=$(nslookup "$EXTERNAL_DOMAIN" 2>/dev/null)
    if echo "$DNS_RESULT" | grep -q "Address"; then
        IP_ADDRESS=$(echo "$DNS_RESULT" | grep "Address:" | tail -1 | awk '{print $2}')
        test_result "DNS resolution" "pass" "Resolves to: $IP_ADDRESS"
    else
        test_result "DNS resolution" "fail" "Domain does not resolve"
    fi
else
    test_result "nslookup available" "warn" "nslookup not available for DNS testing"
fi

echo ""

# Summary
echo "📊 Health Check Summary:"
echo "========================"
TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed! ($TESTS_PASSED/$TOTAL_TESTS)${NC}"
    echo "   Your tunnel is healthy and ready for development."
elif [ $TESTS_PASSED -gt $TESTS_FAILED ]; then
    echo -e "${YELLOW}⚠️  Some issues found ($TESTS_PASSED passed, $TESTS_FAILED failed)${NC}"
    echo "   Your tunnel may work but has some issues to resolve."
else
    echo -e "${RED}❌ Multiple issues detected ($TESTS_PASSED passed, $TESTS_FAILED failed)${NC}"
    echo "   Your tunnel needs attention before it will work properly."
fi

echo ""
echo "📋 Quick Actions:"
if [ $TESTS_FAILED -gt 0 ]; then
    echo "   Fix issues: Review failed tests above"
fi
echo "   Start tunnel: ./smart-start.sh"
echo "   Check status: ./tunnel-status.sh"
echo "   View logs: tail -f /tmp/cloudflare-tunnel-$TUNNEL_NAME.log"
echo "   Test in browser: https://$EXTERNAL_DOMAIN"

# Exit with appropriate code
if [ $TESTS_FAILED -eq 0 ]; then
    exit 0
else
    exit 1
fi
