#!/bin/bash

# Cloudflare Gateway Rules Configuration Script
# This script creates the necessary Gateway firewall rules to allow Wrangler CLI access

echo "🛡️ Cloudflare Gateway Rules Configuration"
echo "=========================================="
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
    echo "  4. Permissions: Account:Cloudflare Tunnel:Edit, Zone:Zone Settings:Edit"
    echo "  5. Account Resources: Include your account"
    echo ""
    exit 1
fi

echo "🔧 Creating Gateway Firewall Rules..."
echo ""

# Function to create a Gateway rule
create_rule() {
    local name="$1"
    local description="$2"
    local domain="$3"
    local priority="$4"
    
    echo "📝 Creating rule: $name"
    
    # API request payload
    cat > /tmp/gateway_rule.json << EOF
{
  "name": "$name",
  "description": "$description",
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
    
    # Make API request
    response=$(curl -s -X POST \
        "$BASE_URL/accounts/$ACCOUNT_ID/gateway/rules" \
        -H "Authorization: Bearer $CF_API_TOKEN" \
        -H "Content-Type: application/json" \
        -d @/tmp/gateway_rule.json)
    
    # Check response
    if echo "$response" | grep -q '"success":true'; then
        echo "   ✅ Successfully created: $name"
        rule_id=$(echo "$response" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
        echo "   🆔 Rule ID: $rule_id"
    else
        echo "   ❌ Failed to create: $name"
        echo "   📄 Response: $response"
    fi
    echo ""
}

# Create the rules
echo "Creating allow rules for development tools..."
echo ""

create_rule \
    "Allow NPM Registry" \
    "Allow npm package installation and updates for development" \
    "registry.npmjs.org" \
    1000

create_rule \
    "Allow NPM CDN" \
    "Allow npm package downloads from CDN" \
    "*.npmjs.org" \
    1001

create_rule \
    "Allow Cloudflare API" \
    "Allow Wrangler CLI to manage Cloudflare Workers" \
    "api.cloudflare.com" \
    1002

create_rule \
    "Allow Node.js Downloads" \
    "Allow Node.js and npm updates" \
    "nodejs.org" \
    1003

create_rule \
    "Allow GitHub" \
    "Allow access to GitHub for npm packages" \
    "github.com" \
    1004

create_rule \
    "Allow GitHub Raw Content" \
    "Allow downloading raw files from GitHub" \
    "raw.githubusercontent.com" \
    1005

create_rule \
    "Allow Apple Captive Portal" \
    "Allow macOS network connectivity checks (critical for network function)" \
    "captive.apple.com" \
    1006

create_rule \
    "Allow Apple Services" \
    "Allow Apple services and updates (important for macOS function)" \
    "*.apple.com" \
    1007

# Clean up temporary file
rm -f /tmp/gateway_rule.json

echo "🧪 Testing npm registry access..."
echo ""

# Test if the rules are working
sleep 5  # Wait for rules to propagate

echo "🔍 Testing registry.npmjs.org access..."
response_code=$(curl -s -o /dev/null -w "%{http_code}" https://registry.npmjs.org/)

if [ "$response_code" -eq 200 ]; then
    echo "   ✅ NPM registry is accessible (HTTP $response_code)"
    echo ""
    echo "🚀 Ready to install Wrangler!"
    echo ""
    echo "Run these commands:"
    echo "   npm config set strict-ssl true"
    echo "   npm install -g wrangler"
    echo "   wrangler --version"
    echo "   wrangler login"
    echo ""
elif [ "$response_code" -eq 303 ]; then
    echo "   ⚠️  Still being blocked (HTTP $response_code)"
    echo "   Wait a few minutes for rules to propagate, then try:"
    echo "   curl -I https://registry.npmjs.org/"
    echo ""
else
    echo "   ❓ Unexpected response code: $response_code"
    echo ""
fi

echo "📋 Next steps:"
echo "=============="
echo ""
echo "1. Wait 2-3 minutes for Gateway rules to propagate"
echo "2. Test access: curl -I https://registry.npmjs.org/"
echo "3. Install Wrangler: npm install -g wrangler"
echo "4. Login: wrangler login"
echo "5. Deploy Workers: cd workers/admin-dashboard && wrangler deploy"
echo ""
echo "📊 Monitor rules in Cloudflare Dashboard:"
echo "   Zero Trust → Gateway → Firewall policies"
echo ""
echo "🔧 If still blocked, check rule priorities ensure Allow rules come before Block rules"
