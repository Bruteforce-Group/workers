#!/bin/bash

# Cloudflare Access Policy Testing Script
# This script helps test the deployed Workers and Access policies

echo "🚀 Cloudflare Access Policy Testing Script"
echo "=========================================="
echo ""

# Test domains
ADMIN_URL="https://admin-test.bozza.au"
DEV_URL="https://dev-test.bozza.au"
EMERGENCY_URL="https://emergency-test.bozza.au"

echo "📋 Testing Domains:"
echo "   Admin Dashboard: $ADMIN_URL"
echo "   Developer Portal: $DEV_URL"
echo "   Emergency Access: $EMERGENCY_URL"
echo ""

# Function to test a URL
test_url() {
    local url=$1
    local name=$2
    echo "🔍 Testing $name..."
    
    # Test if the domain resolves and responds
    if curl -s -I "$url" >/dev/null 2>&1; then
        echo "   ✅ $name: Responds to requests"
        
        # Check if Cloudflare Access is protecting it (should get a 403 or redirect)
        response_code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
        if [ "$response_code" -eq 403 ] || [ "$response_code" -eq 302 ]; then
            echo "   ✅ $name: Protected by Cloudflare Access (HTTP $response_code)"
        elif [ "$response_code" -eq 200 ]; then
            echo "   ⚠️  $name: Responds with 200 - Access may not be configured"
        else
            echo "   ❓ $name: Unexpected response code: $response_code"
        fi
    else
        echo "   ❌ $name: Not responding or not deployed"
    fi
    echo ""
}

echo "🧪 Running connectivity tests..."
echo ""

# Test each URL
test_url "$ADMIN_URL" "Admin Dashboard"
test_url "$DEV_URL" "Developer Portal"
test_url "$EMERGENCY_URL" "Emergency Access"

echo "📊 Test Summary:"
echo "=================="
echo ""
echo "Next steps:"
echo "1. If URLs are not responding, deploy the Workers first"
echo "2. If getting 200 responses, configure Cloudflare Access applications"
echo "3. If getting 403/302, Access is working - test authentication flow"
echo "4. Visit each URL in browser to test full authentication flow"
echo ""
echo "🔐 Authentication Test Checklist:"
echo "  □ Admin Dashboard requires Google MFA (2hr session)"
echo "  □ Developer Portal requires Google MFA (8hr session)"
echo "  □ Emergency Access requires Google MFA + justification (1hr session)"
echo "  □ All require Australia geographic location"
echo "  □ Correct user groups are enforced"
echo "  □ Session timeouts work as expected"
echo ""
echo "📈 Monitoring locations:"
echo "  • Cloudflare Dashboard > Access > Analytics"
echo "  • Workers & Pages > Your Worker > Real-time Logs"
echo "  • DNS > Analytics for domain traffic"
echo ""
echo "✅ For manual browser testing, open these URLs:"
echo "   $ADMIN_URL"
echo "   $DEV_URL"
echo "   $EMERGENCY_URL"
