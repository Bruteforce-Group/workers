#!/bin/bash

# Cloudflare Gateway Logs Analysis Script
# This script fetches recent Gateway logs and analyzes blocked traffic

echo "🔍 Cloudflare Gateway Logs Analysis"
echo "===================================="
echo ""

# Configuration
ACCOUNT_ID="0b0ee2b5eaf1fb8a2612e40ab6488052"
BASE_URL="https://api.cloudflare.com/client/v4"

# Check if API token is set
if [ -z "$CF_API_TOKEN" ]; then
    echo "❌ Error: CF_API_TOKEN environment variable is not set"
    echo ""
    echo "Please set your Cloudflare API Token:"
    echo "  export CF_API_TOKEN='your-api-token-here'"
    echo ""
    echo "To create an API token:"
    echo "  1. Go to Cloudflare Dashboard → My Profile → API Tokens"
    echo "  2. Click 'Create Token'"
    echo "  3. Use 'Custom token' template"
    echo "  4. Permissions: Account:Logs:Read, Account:Gateway:Read"
    echo "  5. Account Resources: Include your account"
    echo ""
    exit 1
fi

# Get current time and 1 hour ago for log filtering
END_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
START_TIME=$(date -u -d '1 hour ago' +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -j -f "%Y-%m-%d %H:%M:%S" "$(date -u -d '1 hour ago' +"%Y-%m-%d %H:%M:%S")" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -v-1H +"%Y-%m-%dT%H:%M:%SZ")

echo "📊 Fetching Gateway logs for the last hour..."
echo "Time range: $START_TIME to $END_TIME"
echo ""

# Fetch Gateway logs
echo "🔍 Retrieving blocked requests..."
response=$(curl -s -X GET \
    "$BASE_URL/accounts/$ACCOUNT_ID/gateway/logs" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json" \
    -G \
    --data-urlencode "since=$START_TIME" \
    --data-urlencode "until=$END_TIME" \
    --data-urlencode "filters=Action==block")

# Check if request was successful
if ! echo "$response" | grep -q '"success":true'; then
    echo "❌ Failed to fetch logs"
    echo "Response: $response"
    exit 1
fi

# Save raw logs for analysis
echo "$response" > /tmp/gateway_logs.json

# Parse and analyze the logs
echo "📋 Analyzing blocked requests..."
echo ""

# Extract blocked domains and count occurrences
blocked_domains=$(echo "$response" | jq -r '.result[] | select(.Action == "block") | .Destination' 2>/dev/null | sort | uniq -c | sort -nr)

if [ -z "$blocked_domains" ]; then
    echo "✅ No blocked requests found in the last hour!"
    echo ""
    echo "This could mean:"
    echo "  • Your Gateway rules are working well"
    echo "  • No attempts to access blocked content"
    echo "  • You may need to check a longer time period"
    echo ""
    exit 0
fi

echo "🚫 Top Blocked Domains (last hour):"
echo "==================================="
echo "$blocked_domains" | head -20
echo ""

# Analyze specific categories
echo "🔍 Analysis and Recommendations:"
echo "================================"
echo ""

# Create analysis file
cat > /tmp/blocked_analysis.txt << 'EOF'
# Blocked Domains Analysis

## Development Tools (Likely should be allowed)
- registry.npmjs.org - NPM package registry (ALLOW for development)
- *.npmjs.org - NPM CDN (ALLOW for development)
- api.cloudflare.com - Cloudflare API (ALLOW for Wrangler CLI)
- github.com - Code repository (ALLOW for development)
- raw.githubusercontent.com - Raw file access (ALLOW for packages)
- nodejs.org - Node.js official site (ALLOW for updates)

## Code/Package Repositories
- packagist.org - PHP packages (ALLOW if using PHP)
- pypi.org - Python packages (ALLOW if using Python)
- rubygems.org - Ruby gems (ALLOW if using Ruby)
- nuget.org - .NET packages (ALLOW if using .NET)

## CDN/Static Assets
- cdnjs.cloudflare.com - Open source CDN (LIKELY ALLOW)
- unpkg.com - NPM-based CDN (ALLOW for development)
- jsdelivr.net - Free CDN (ALLOW for development)

## Security/Malware (Should stay blocked)
- Known malware domains
- Phishing sites
- Cryptocurrency mining sites
- Adult content (if policy requires)

## Social Media/Entertainment (Policy dependent)
- Social media platforms
- Streaming services
- Gaming sites
- Personal cloud storage

## Advertising/Tracking (Usually keep blocked)
- Ad networks
- Tracking pixels
- Analytics services (except business-critical ones)
EOF

# Function to categorize and recommend domains
analyze_domain() {
    local domain="$1"
    local count="$2"
    
    case "$domain" in
        *npmjs.org|registry.npmjs.org)
            echo "🟢 RECOMMEND ALLOW: $domain ($count requests) - NPM package registry (development tool)"
            ;;
        api.cloudflare.com|dash.cloudflare.com)
            echo "🟢 RECOMMEND ALLOW: $domain ($count requests) - Cloudflare API (needed for Wrangler)"
            ;;
        github.com|*.github.com|raw.githubusercontent.com)
            echo "🟢 RECOMMEND ALLOW: $domain ($count requests) - GitHub (code repository/packages)"
            ;;
        nodejs.org|*.nodejs.org)
            echo "🟢 RECOMMEND ALLOW: $domain ($count requests) - Node.js official site"
            ;;
        packagist.org|pypi.org|rubygems.org|nuget.org)
            echo "🟡 CONSIDER ALLOW: $domain ($count requests) - Package manager (if language is used)"
            ;;
        cdnjs.cloudflare.com|unpkg.com|jsdelivr.net)
            echo "🟡 CONSIDER ALLOW: $domain ($count requests) - Development CDN"
            ;;
        *ads*|*tracking*|*analytics*|*doubleclick*|*googleanalytics*)
            echo "🔴 KEEP BLOCKED: $domain ($count requests) - Advertising/tracking"
            ;;
        *malware*|*phishing*|*crypto*|*mining*)
            echo "🔴 KEEP BLOCKED: $domain ($count requests) - Security threat"
            ;;
        *facebook*|*twitter*|*instagram*|*tiktok*|*youtube*)
            echo "🟡 POLICY DECISION: $domain ($count requests) - Social media (depends on policy)"
            ;;
        *)
            echo "❓ REVIEW NEEDED: $domain ($count requests) - Unknown category"
            ;;
    esac
}

# Analyze each blocked domain
echo "🎯 Domain-by-domain Analysis:"
echo "============================="
while IFS= read -r line; do
    if [ -n "$line" ]; then
        count=$(echo "$line" | awk '{print $1}')
        domain=$(echo "$line" | awk '{print $2}')
        analyze_domain "$domain" "$count"
    fi
done <<< "$blocked_domains"

echo ""
echo "📊 Summary Statistics:"
echo "===================="

# Count categories
total_blocked=$(echo "$blocked_domains" | wc -l)
dev_tools=$(echo "$blocked_domains" | grep -E "(npmjs|github|nodejs|cloudflare\.com|packagist|pypi|rubygems|nuget)" | wc -l)
cdn_services=$(echo "$blocked_domains" | grep -E "(cdnjs|unpkg|jsdelivr)" | wc -l)
ads_tracking=$(echo "$blocked_domains" | grep -E "(ads|tracking|analytics|doubleclick)" | wc -l)

echo "• Total unique blocked domains: $total_blocked"
echo "• Development tools: $dev_tools"
echo "• CDN services: $cdn_services" 
echo "• Ads/tracking: $ads_tracking"
echo ""

echo "🚀 Recommended Actions:"
echo "======================"
echo ""
echo "HIGH PRIORITY (Enable development):"
echo "  □ Allow registry.npmjs.org"
echo "  □ Allow api.cloudflare.com"
echo "  □ Allow github.com"
echo "  □ Allow nodejs.org"
echo ""
echo "MEDIUM PRIORITY (Based on your tech stack):"
echo "  □ Review language-specific package managers"
echo "  □ Consider allowing development CDNs"
echo ""
echo "LOW PRIORITY (Policy dependent):"
echo "  □ Review social media access needs"
echo "  □ Consider business-critical services"
echo ""
echo "KEEP BLOCKED:"
echo "  ✓ Advertising/tracking domains"
echo "  ✓ Known security threats"
echo "  ✓ Non-business related sites"
echo ""

# Create allow rules script based on findings
echo "💡 Would you like to create allow rules for development tools? (y/n)"
read -r create_rules

if [ "$create_rules" = "y" ] || [ "$create_rules" = "Y" ]; then
    echo ""
    echo "🔧 Creating development tool allow rules..."
    
    # Extract development-related blocked domains
    dev_domains=$(echo "$blocked_domains" | grep -E "(npmjs|github|nodejs|cloudflare\.com)" | awk '{print $2}')
    
    priority=1000
    for domain in $dev_domains; do
        echo "Creating allow rule for: $domain"
        
        cat > /tmp/dev_rule.json << EOF
{
  "name": "Allow Development - $domain",
  "description": "Allow access to $domain for development tools",
  "precedence": $priority,
  "enabled": true,
  "action": "allow",
  "traffic": "http",
  "rule": {
    "http": {
      "hostname": {
        "in": ["$domain"]
      }
    }
  }
}
EOF
        
        rule_response=$(curl -s -X POST \
            "$BASE_URL/accounts/$ACCOUNT_ID/gateway/rules" \
            -H "Authorization: Bearer $CF_API_TOKEN" \
            -H "Content-Type: application/json" \
            -d @/tmp/dev_rule.json)
        
        if echo "$rule_response" | grep -q '"success":true'; then
            echo "  ✅ Created allow rule for $domain"
        else
            echo "  ❌ Failed to create rule for $domain"
        fi
        
        priority=$((priority + 1))
    done
    
    rm -f /tmp/dev_rule.json
fi

echo ""
echo "📁 Full log data saved to: /tmp/gateway_logs.json"
echo "🔍 You can review detailed logs with: jq '.' /tmp/gateway_logs.json"

# Cleanup
rm -f /tmp/blocked_analysis.txt
