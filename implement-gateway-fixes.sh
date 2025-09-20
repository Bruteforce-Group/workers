#!/bin/bash

# Implement Gateway Fixes Script
# Creates the necessary Gateway firewall rules to restore system and development functionality

echo "🛡️ Implementing Critical Gateway Fixes"
echo "======================================="
echo ""

# Configuration
ACCOUNT_ID="0b0ee2b5eaf1fb8a2612e40ab6488052"
BASE_URL="https://api.cloudflare.com/client/v4"
EMAIL="admin@bozza.au"

# Check if API key is available
if [ -n "$CLOUDFLARE_API_KEY" ]; then
    echo "✅ Using CLOUDFLARE_API_KEY for authentication"
    API_KEY="$CLOUDFLARE_API_KEY"
elif [ -n "$CF_API_TOKEN" ]; then
    echo "✅ Using CF_API_TOKEN for authentication"
    API_TOKEN="$CF_API_TOKEN"
else
    echo "❌ Error: No Cloudflare API credentials found"
    echo "Expected: CLOUDFLARE_API_KEY or CF_API_TOKEN environment variable"
    exit 1
fi

echo "🔧 Creating critical Gateway firewall rules..."
echo ""

# Function to create a Gateway rule with API Key
create_rule_with_key() {
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
    
    # Make API request with API Key
    response=$(curl -s -X POST \
        "$BASE_URL/accounts/$ACCOUNT_ID/gateway/rules" \
        -H "X-Auth-Key: $API_KEY" \
        -H "X-Auth-Email: $EMAIL" \
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

# Function to create a Gateway rule with API Token
create_rule_with_token() {
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
    
    # Make API request with Bearer token
    response=$(curl -s -X POST \
        "$BASE_URL/accounts/$ACCOUNT_ID/gateway/rules" \
        -H "Authorization: Bearer $API_TOKEN" \
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

# Determine which function to use
if [ -n "$API_KEY" ]; then
    create_rule() { create_rule_with_key "$@"; }
else
    create_rule() { create_rule_with_token "$@"; }
fi

# PHASE 1: CRITICAL SYSTEM FIXES (Apple domains)
echo "🍎 PHASE 1: Creating CRITICAL Apple domain rules..."
echo "=================================================="
echo ""

create_rule \
    "Allow Apple Captive Portal" \
    "CRITICAL - Allow macOS network connectivity checks (required for proper network function)" \
    "captive.apple.com" \
    990

create_rule \
    "Allow Apple Services" \
    "CRITICAL - Allow Apple services and updates (required for macOS function)" \
    "*.apple.com" \
    991

# PHASE 2: DEVELOPMENT TOOLS
echo "🛠️ PHASE 2: Creating development tool rules..."
echo "=============================================="
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

# Clean up temporary file
rm -f /tmp/gateway_rule.json

echo "🧪 Testing critical connectivity..."
echo "=================================="
echo ""

# Wait for rules to propagate
echo "⏰ Waiting 30 seconds for rules to propagate..."
sleep 30

echo "🔍 Testing Apple captive portal..."
response_code=$(curl -s -o /dev/null -w "%{http_code}" https://captive.apple.com/)

if [ "$response_code" -eq 200 ]; then
    echo "   ✅ Apple captive portal is accessible (HTTP $response_code)"
    echo "   🍎 macOS network connectivity restored!"
elif [ "$response_code" -eq 303 ]; then
    echo "   ⚠️  Still being blocked (HTTP $response_code)"
    echo "   Wait a few more minutes for rules to propagate"
else
    echo "   ❓ Unexpected response code: $response_code"
fi

echo ""
echo "🔍 Testing NPM registry..."
response_code=$(curl -s -o /dev/null -w "%{http_code}" https://registry.npmjs.org/)

if [ "$response_code" -eq 200 ]; then
    echo "   ✅ NPM registry is accessible (HTTP $response_code)"
    echo "   🚀 Ready to install Wrangler!"
    echo ""
    echo "Run these commands to continue:"
    echo "   npm config set strict-ssl true"
    echo "   npm install -g wrangler"
    echo "   wrangler --version"
    echo "   wrangler login"
elif [ "$response_code" -eq 303 ]; then
    echo "   ⚠️  Still being blocked (HTTP $response_code)"
    echo "   Wait a few more minutes for rules to propagate"
else
    echo "   ❓ Unexpected response code: $response_code"
fi

echo ""
echo "📊 Implementation Summary:"
echo "========================="
echo ""
echo "✅ Created critical Apple domain rules (macOS system function)"
echo "✅ Created development tool rules (npm, GitHub, Node.js, Cloudflare)"
echo ""
echo "🧪 Next steps:"
echo "1. Wait 2-3 more minutes for full rule propagation"
echo "2. Test Apple connectivity: ./test-apple-connectivity.sh"
echo "3. Test development tools: ./test-access-policies.sh" 
echo "4. Install Wrangler: npm install -g wrangler"
echo "5. Deploy Workers: cd workers/admin-dashboard && wrangler deploy"
echo ""
echo "🔧 If still blocked, check rule priorities in Dashboard:"
echo "   Zero Trust → Gateway → Firewall policies"
echo "   Ensure Allow rules have lower priority numbers than Block rules"
