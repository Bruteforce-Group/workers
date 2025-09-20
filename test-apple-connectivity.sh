#!/bin/bash

# Apple Domain Connectivity Test Script
# Tests critical Apple domains for macOS network functionality

echo "🍎 Apple Domain Connectivity Test"
echo "================================="
echo ""

# Apple domains critical for macOS function
apple_domains=(
    "captive.apple.com"
    "www.apple.com" 
    "gsp1.apple.com"
    "configuration.apple.com"
    "time.apple.com"
)

echo "🔍 Testing Apple domains..."
echo ""

# Test each Apple domain
for domain in "${apple_domains[@]}"; do
    echo -n "Testing $domain: "
    response_code=$(curl -s -o /dev/null -w "%{http_code}" "https://$domain/" 2>/dev/null)
    
    case "$response_code" in
        200)
            echo "✅ Accessible (HTTP $response_code)"
            ;;
        303)
            echo "🚫 BLOCKED - redirected to Gateway block page"
            ;;
        301|302)
            echo "🔄 Redirect (HTTP $response_code) - may be accessible"
            ;;
        *)
            echo "❓ Status: HTTP $response_code"
            ;;
    esac
done

echo ""
echo "📊 Summary:"
echo "==========="

blocked_count=$(for domain in "${apple_domains[@]}"; do 
    response_code=$(curl -s -o /dev/null -w "%{http_code}" "https://$domain/" 2>/dev/null)
    [ "$response_code" = "303" ] && echo "blocked"
done | wc -l)

accessible_count=$(for domain in "${apple_domains[@]}"; do 
    response_code=$(curl -s -o /dev/null -w "%{http_code}" "https://$domain/" 2>/dev/null)
    [ "$response_code" = "200" ] && echo "accessible"
done | wc -l)

echo "• Apple domains tested: ${#apple_domains[@]}"
echo "• Currently blocked: $blocked_count"  
echo "• Currently accessible: $accessible_count"
echo ""

if [ "$blocked_count" -gt 0 ]; then
    echo "⚠️  WARNING: Apple domains are blocked!"
    echo ""
    echo "🚨 IMPACT:"
    echo "• macOS network connectivity checks may fail"
    echo "• System services may not function properly"  
    echo "• Network detection may be unreliable"
    echo "• Apple services and updates may be blocked"
    echo ""
    echo "🔧 URGENT ACTION REQUIRED:"
    echo "Add these Gateway allow rules immediately:"
    echo ""
    echo "1. Allow Apple Captive Portal:"
    echo "   Domain: captive.apple.com"
    echo "   Priority: 999 (highest)"
    echo ""
    echo "2. Allow Apple Services:"
    echo "   Domain: *.apple.com"
    echo "   Priority: 998"
    echo ""
    echo "These are CRITICAL for macOS system function!"
else
    echo "✅ All Apple domains are accessible"
    echo "macOS network functionality should work normally"
fi

echo ""
echo "🛠️ To fix blocked Apple domains:"
echo "1. Go to Cloudflare Dashboard → Zero Trust → Gateway → Firewall policies"
echo "2. Add allow rules for the blocked domains above"
echo "3. Set high priority (lower numbers = higher priority)"
echo "4. Test again: ./test-apple-connectivity.sh"
echo ""
echo "📞 This test focuses on Apple domains only."
echo "Run ./test-access-policies.sh to test all development domains."
