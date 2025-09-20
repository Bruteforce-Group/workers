#!/bin/bash

# Gateway Implementation Monitoring Script
# Run this to track progress as you implement rules manually

echo "📊 Gateway Implementation Progress Monitor"
echo "=========================================="
echo ""

# Function to test a domain and show status
test_domain() {
    local domain="$1"
    local description="$2"
    local priority="$3"
    
    echo -n "Testing $domain ($description): "
    response_code=$(curl -s -o /dev/null -w "%{http_code}" "https://$domain/" 2>/dev/null)
    
    case "$response_code" in
        200)
            echo "✅ WORKING (HTTP $response_code) - Rule successfully applied!"
            return 0
            ;;
        301|302)
            echo "🔄 REDIRECT (HTTP $response_code) - May be working, check manually"
            return 1
            ;;
        303)
            echo "🚫 BLOCKED (HTTP $response_code) - Rule not yet applied or needs priority adjustment"
            return 1
            ;;
        *)
            echo "❓ STATUS: HTTP $response_code"
            return 1
            ;;
    esac
}

# Function to show implementation phase status
show_phase_status() {
    local phase_name="$1"
    local phase_desc="$2"
    shift 2
    local domains=("$@")
    
    echo "🔍 $phase_name: $phase_desc"
    echo "$(printf '%0.s=' {1..60})"
    echo ""
    
    local working_count=0
    local total_count=${#domains[@]}
    
    for domain_info in "${domains[@]}"; do
        IFS='|' read -r domain description priority <<< "$domain_info"
        if test_domain "$domain" "$description" "$priority"; then
            ((working_count++))
        fi
    done
    
    echo ""
    echo "📊 Phase Status: $working_count/$total_count domains working"
    
    if [ $working_count -eq $total_count ]; then
        echo "✅ $phase_name COMPLETE!"
    else
        echo "⚠️  $phase_name incomplete - $(($total_count - $working_count)) domains still blocked"
    fi
    echo ""
}

while true; do
    clear
    echo "📊 Gateway Implementation Progress Monitor"
    echo "=========================================="
    echo "🕒 $(date)"
    echo ""
    
    # Phase 1: Apple domains (System Critical)
    apple_domains=(
        "captive.apple.com|Apple Captive Portal (MOST CRITICAL)|990"
        "www.apple.com|Apple Services|991"
        "gsp1.apple.com|Apple Geolocation Services|991"
        "time.apple.com|Apple Time Services|991"
    )
    
    show_phase_status "PHASE 1 - APPLE DOMAINS" "Critical for macOS system function" "${apple_domains[@]}"
    
    # Phase 2: Development tools
    dev_domains=(
        "registry.npmjs.org|NPM Registry (Critical for Wrangler)|1000"
        "api.cloudflare.com|Cloudflare API (Wrangler requirement)|1001"
        "github.com|GitHub (Code repositories)|1002"
        "nodejs.org|Node.js (Official site)|1003"
    )
    
    show_phase_status "PHASE 2 - DEVELOPMENT TOOLS" "Essential for development workflow" "${dev_domains[@]}"
    
    # Overall progress
    echo "🎯 OVERALL IMPLEMENTATION STATUS:"
    echo "$(printf '%0.s=' {1..60})"
    
    # Test all critical domains
    all_domains=("${apple_domains[@]}" "${dev_domains[@]}")
    working_total=0
    
    for domain_info in "${all_domains[@]}"; do
        IFS='|' read -r domain description priority <<< "$domain_info"
        response_code=$(curl -s -o /dev/null -w "%{http_code}" "https://$domain/" 2>/dev/null)
        if [ "$response_code" = "200" ]; then
            ((working_total++))
        fi
    done
    
    total_domains=${#all_domains[@]}
    percentage=$((working_total * 100 / total_domains))
    
    echo "Progress: $working_total/$total_domains domains working ($percentage%)"
    
    if [ $working_total -eq $total_domains ]; then
        echo ""
        echo "🎉 ALL RULES SUCCESSFULLY IMPLEMENTED!"
        echo "✅ macOS system connectivity restored"
        echo "✅ Development workflow unblocked"
        echo ""
        echo "🚀 Ready for next steps:"
        echo "   npm install -g wrangler"
        echo "   wrangler --version"
        echo "   wrangler login"
        echo ""
        echo "Press Ctrl+C to exit monitoring..."
    else
        echo ""
        echo "📋 Manual Implementation Status:"
        if [ $working_total -eq 0 ]; then
            echo "🔴 NOT STARTED - Begin with Apple domains (Phase 1)"
        elif [ $working_total -lt 4 ]; then
            echo "🟡 IN PROGRESS - Continue with Apple domains (Phase 1)"
        elif [ $working_total -lt 8 ]; then
            echo "🟡 APPLE COMPLETE - Continue with development tools (Phase 2)"
        else
            echo "🟢 NEARLY COMPLETE - Final domains remaining"
        fi
        echo ""
        echo "🔧 Implementation Guide: ./MANUAL_IMPLEMENTATION_GUIDE.md"
        echo "📍 Dashboard: https://dash.cloudflare.com/ → Zero Trust → Gateway → Firewall policies"
    fi
    
    echo ""
    echo "$(printf '%0.s─' {1..60})"
    echo "🔄 Refreshing in 30 seconds... (Press Ctrl+C to stop)"
    
    # Wait with countdown
    for i in {30..1}; do
        echo -ne "\rNext update in: $i seconds... "
        sleep 1
    done
    echo ""
done
