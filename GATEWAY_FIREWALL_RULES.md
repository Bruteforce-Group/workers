# 🛡️ Cloudflare Gateway Firewall Rules for Wrangler CLI

## 🎯 Issue Identified
Your Cloudflare Gateway is currently blocking access to npm registry and related services needed for Wrangler CLI installation and operation.

**Current Block Details:**
- **Blocked URL**: `registry.npmjs.org`
- **Rule ID**: `a026b492-40f5-461b-8bc8-c808a243f703`
- **Account ID**: `0b0ee2b5eaf1fb8a2612e40ab6488052`

## 🔧 Required Gateway Policy Changes

### Option 1: Allow Specific Development Domains (Recommended)

Add these **Allow** rules to your Gateway firewall policies:

#### 1. NPM Registry Access
```
Policy Name: Allow NPM Registry
Action: Allow
Traffic: HTTP/HTTPS
Destination: registry.npmjs.org
Priority: High (e.g., 1000)
Description: Allow npm package installation and updates
```

#### 2. NPM Content Delivery Network
```
Policy Name: Allow NPM CDN
Action: Allow  
Traffic: HTTP/HTTPS
Destination: *.npmjs.org
Priority: High (e.g., 1001)
Description: Allow npm package downloads
```

#### 3. Cloudflare API Access (for Wrangler)
```
Policy Name: Allow Cloudflare API
Action: Allow
Traffic: HTTP/HTTPS
Destination: api.cloudflare.com
Priority: High (e.g., 1002)
Description: Allow Wrangler CLI to manage Workers
```

#### 4. Node.js Official Downloads
```
Policy Name: Allow Node.js Downloads
Action: Allow
Traffic: HTTP/HTTPS
Destination: nodejs.org
Priority: High (e.g., 1003)
Description: Allow Node.js and npm updates
```

### Option 2: Developer Machine Exception (Alternative)

Create a device-specific exception for your development machine:

```
Policy Name: Developer Machine - Full NPM Access
Action: Allow
Traffic: HTTP/HTTPS
Source IP: [Your current IP: 2001:8003:e01d:5c03:24a5:554d:1e2f:aff0]
Destination: *.npmjs.org, api.cloudflare.com, *.nodejs.org
Priority: High (e.g., 999)
Description: Allow development tools access for admin workstation
```

## 🔄 Implementation Steps

### Step 1: Access Gateway Policies
1. **Login to Cloudflare Dashboard**
2. **Go to Zero Trust → Gateway → Firewall policies**
3. **Click "Add a policy"**

### Step 2: Create Allow Rules
For each rule above:

1. **Set Policy Name** (e.g., "Allow NPM Registry")
2. **Select "HTTP" traffic**
3. **Set Action to "Allow"**
4. **Configure Traffic criteria:**
   - **Destination** → **Domain** → Add domain (e.g., `registry.npmjs.org`)
5. **Set Priority** (lower number = higher priority)
6. **Add Description**
7. **Click "Save"**

### Step 3: Verify Rule Order
Ensure your new **Allow** rules appear **BEFORE** any **Block** rules that might catch these domains.

Priority order should be:
```
1000 - Allow NPM Registry ✅
1001 - Allow NPM CDN ✅  
1002 - Allow Cloudflare API ✅
1003 - Allow Node.js Downloads ✅
...
2000+ - Your existing Block rules ❌
```

## 🧪 Testing the Changes

### Immediate Test
After adding the rules, test access:

```bash
# Test npm registry access
curl -I https://registry.npmjs.org/

# Should return: HTTP/1.1 200 OK (not a redirect to blocked page)
```

### Install Wrangler
Once rules are active:

```bash
# Reset npm SSL settings
npm config set strict-ssl true

# Install Wrangler globally
npm install -g wrangler

# Verify installation
wrangler --version

# Login to Cloudflare (will open browser)
wrangler login
```

## 🎯 Specific Domains to Allow

### Core NPM Infrastructure
- `registry.npmjs.org` - Main package registry
- `registry.yarnpkg.com` - Yarn registry (if using Yarn)
- `skimdb.npmjs.com` - NPM database
- `replicate.npmjs.com` - NPM replication

### Cloudflare Services (for Wrangler)
- `api.cloudflare.com` - Main Cloudflare API
- `dash.cloudflare.com` - Dashboard authentication
- `workers.dev` - Workers platform
- `pages.dev` - Pages platform

### Node.js Infrastructure
- `nodejs.org` - Official Node.js site
- `github.com` - Many packages hosted here
- `raw.githubusercontent.com` - Raw file access

## 🔒 Security Considerations

### Minimal Access Approach
Instead of allowing all domains, consider:

1. **Time-based rules** - Allow access only during development hours
2. **User-specific rules** - Apply only to developer accounts
3. **Location-based rules** - Apply only from office/home networks

### Example Time-Based Rule
```
Policy Name: NPM Access - Business Hours
Action: Allow
Traffic: HTTP/HTTPS  
Destination: registry.npmjs.org
Schedule: Monday-Friday, 9 AM - 6 PM (your timezone)
Users: developer@bozza.au
```

## 🚨 Quick Fix for Immediate Access

If you need immediate access, temporarily disable the blocking rule:

1. **Go to Gateway → Firewall policies**
2. **Find rule ID**: `a026b492-40f5-461b-8bc8-c808a243f703`
3. **Edit the rule** and change action to "Allow" or disable it
4. **Install Wrangler**
5. **Re-enable the rule** and add specific allows as above

## 📋 Verification Checklist

After implementing the rules:

- [ ] `curl -I https://registry.npmjs.org/` returns 200 OK
- [ ] `npm install -g wrangler` works without errors
- [ ] `wrangler --version` shows version number
- [ ] `wrangler login` opens browser successfully
- [ ] Can deploy Workers with `wrangler deploy`

## 🔧 Alternative: Bypass Gateway for Development

If organizational policy prevents allowing these domains, consider:

### Local Development Proxy
```bash
# Use a different npm registry (if allowed)
npm config set registry https://registry.yarnpkg.com/

# Or use corporate proxy settings
npm config set proxy http://your-corporate-proxy:port
npm config set https-proxy http://your-corporate-proxy:port
```

### VPN/Network Exception
- Connect via VPN that bypasses Gateway
- Use mobile hotspot for development setup
- Request network exception for development machine

---

## 📞 Need Help?

If you encounter issues implementing these rules:
1. **Check Gateway Analytics** to see what's still being blocked
2. **Review rule priorities** to ensure Allow rules come first
3. **Test with specific domains** one at a time
4. **Monitor Gateway logs** during npm/wrangler operations

The key is ensuring your Allow rules have **higher priority** (lower numbers) than any Block rules that might catch these development domains.
