# 🛡️ Gateway Firewall Solutions - Quick Reference

## 🎯 Problem Summary
Your Cloudflare Gateway is blocking npm registry access, preventing Wrangler CLI installation.

**Current Block:**
- URL: `registry.npmjs.org`
- Rule ID: `a026b492-40f5-461b-8bc8-c808a243f703`
- Status: **BLOCKED** → Redirected to `blocked.teams.cloudflare.com`

## 🚀 Solution Options

### Option A: Manual Dashboard Configuration (Recommended)
**Time: ~5 minutes | Difficulty: Easy**

1. **Go to:** Cloudflare Dashboard → Zero Trust → Gateway → Firewall policies
2. **Click:** "Add a policy"
3. **Create these Allow rules** (in this order):

```
Priority 1000: Allow NPM Registry
- Action: Allow
- Traffic: HTTP
- Destination: registry.npmjs.org

Priority 1001: Allow NPM CDN  
- Action: Allow
- Traffic: HTTP
- Destination: *.npmjs.org

Priority 1002: Allow Cloudflare API
- Action: Allow  
- Traffic: HTTP
- Destination: api.cloudflare.com
```

4. **Ensure** Allow rules appear **BEFORE** Block rules in the list
5. **Test:** `curl -I https://registry.npmjs.org/` (should return 200 OK)

### Option B: Automated API Script
**Time: ~2 minutes | Difficulty: Medium**

1. **Get Cloudflare API Token:**
   - Dashboard → My Profile → API Tokens → Create Token
   - Template: Custom token
   - Permissions: Account:Gateway:Edit

2. **Set environment variable:**
   ```bash
   export CF_API_TOKEN="your-token-here"
   ```

3. **Run the automation script:**
   ```bash
   ./create-gateway-rules.sh
   ```

### Option C: Quick Temporary Fix
**Time: ~1 minute | Difficulty: Easy**

1. **Find the blocking rule** in Gateway → Firewall policies
2. **Look for rule ID:** `a026b492-40f5-461b-8bc8-c808a243f703`
3. **Temporarily disable** or change action to "Allow"
4. **Install Wrangler** quickly
5. **Re-enable** the rule and add specific allows

## 🧪 Testing Steps

After implementing any solution:

```bash
# Test 1: Basic connectivity
curl -I https://registry.npmjs.org/
# Expected: HTTP/1.1 200 OK

# Test 2: Install Wrangler
npm config set strict-ssl true
npm install -g wrangler
# Expected: Success without errors

# Test 3: Verify Wrangler
wrangler --version
# Expected: Version number displayed

# Test 4: Login to Cloudflare
wrangler login
# Expected: Browser opens for authentication
```

## ⚡ Quick Action Plan

**For immediate results, follow this sequence:**

1. **Open Cloudflare Dashboard** in browser
2. **Navigate to:** Zero Trust → Gateway → Firewall policies
3. **Add Allow rule:**
   - Name: "Allow NPM Registry"
   - Traffic: HTTP
   - Action: Allow
   - Destination: registry.npmjs.org
   - Priority: 1000 (or higher than existing blocks)
4. **Save** and wait 30 seconds
5. **Test:** `curl -I https://registry.npmjs.org/`
6. **If successful:** `npm install -g wrangler`

## 🔒 Security Best Practices

### Minimal Access Approach
Instead of wildcard domains, allow specific ones:
- ✅ `registry.npmjs.org` (npm packages)
- ✅ `api.cloudflare.com` (Wrangler API)
- ✅ `nodejs.org` (Node.js updates)
- ❌ `*.com` (too broad)

### Time-Based Restrictions
Consider limiting to business hours:
```
Schedule: Monday-Friday, 9 AM - 6 PM
Users: developer@bozza.au
Location: Office network only
```

### User-Specific Rules
Apply only to developer accounts:
```
Identity: Email equals "your-email@bozza.au"
Device: Specific device posture
```

## 📊 Domains to Allow

### Essential for Wrangler:
- `registry.npmjs.org` - Core npm registry
- `api.cloudflare.com` - Wrangler API access
- `dash.cloudflare.com` - Authentication

### Optional for full development:
- `github.com` - Package hosting
- `raw.githubusercontent.com` - Raw file downloads
- `nodejs.org` - Node.js updates

## 🐛 Troubleshooting

### Still Getting 303 Redirects?
1. Check rule priority (Allow must come before Block)
2. Wait 2-3 minutes for propagation
3. Clear browser cache/try incognito
4. Verify rule is enabled

### Wrangler Login Issues?
1. Ensure `dash.cloudflare.com` is allowed
2. Check browser popup blockers
3. Try `wrangler login --browser=false` for manual token

### Permission Denied on npm install?
1. Try with sudo: `sudo npm install -g wrangler`
2. Or use local install: `npm install wrangler`
3. Check npm permissions: `npm config get prefix`

## ✅ Success Indicators

You'll know it's working when:
- `curl -I https://registry.npmjs.org/` returns **200 OK**
- `npm install -g wrangler` completes **without errors**
- `wrangler login` opens browser **successfully**
- Can deploy workers with `wrangler deploy`

## 📞 Next Steps After Fix

Once Wrangler is installed:

```bash
# Navigate to each worker directory and deploy
cd workers/admin-dashboard
wrangler deploy

cd ../developer-portal  
wrangler deploy

cd ../emergency-access
wrangler deploy

# Test the deployed workers
../test-access-policies.sh
```

---

**Choose your preferred solution above and implement it now to unblock Wrangler CLI installation!**
