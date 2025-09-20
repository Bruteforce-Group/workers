# Cloudflare Access Test Workers - Deployment Instructions

## Overview
This document provides instructions for deploying the three Cloudflare Access test Workers to verify your Zero Trust security policies.

## Workers Created
1. **Admin Dashboard Test** (`admin-test.bozza.au`) - Tier 3 High Security
2. **Developer Portal Test** (`dev-test.bozza.au`) - Tier 2 Standard Access  
3. **Emergency Access Test** (`emergency-test.bozza.au`) - Tier 4 Maximum Security

## Option 1: Deploy via Cloudflare Dashboard (Recommended)

### Step 1: Create DNS Records
First, create DNS records for the test subdomains in your Cloudflare dashboard:

1. Go to **DNS** > **Records**
2. Add these A records (pointed to 192.0.2.1 as placeholder):
   - `admin-test.bozza.au` → `192.0.2.1` (Proxied)
   - `dev-test.bozza.au` → `192.0.2.1` (Proxied)
   - `emergency-test.bozza.au` → `192.0.2.1` (Proxied)

### Step 2: Deploy Workers via Dashboard

For each Worker:

1. Go to **Workers & Pages** > **Create application** > **Create Worker**
2. Name the Worker:
   - `admin-dashboard-test`
   - `developer-portal-test`
   - `emergency-access-test`
3. Copy and paste the respective `index.js` file content
4. Click **Save and Deploy**

### Step 3: Configure Custom Domains

For each deployed Worker:

1. Go to **Workers & Pages** > Select your Worker > **Settings** > **Triggers**
2. Click **Add Custom Domain**
3. Add the corresponding domain:
   - Admin Dashboard: `admin-test.bozza.au`
   - Developer Portal: `dev-test.bozza.au`
   - Emergency Access: `emergency-test.bozza.au`

## Option 2: Deploy via Wrangler CLI

If you have Wrangler installed and working:

```bash
# Deploy Admin Dashboard
cd workers/admin-dashboard
wrangler deploy

# Deploy Developer Portal
cd ../developer-portal
wrangler deploy

# Deploy Emergency Access
cd ../emergency-access
wrangler deploy
```

## Step 4: Configure Cloudflare Access Applications

After deployment, configure Access applications for each test domain:

### 1. Admin Dashboard (admin-test.bozza.au)
- **Application Type**: Self-hosted
- **Session Duration**: 2 hours
- **Policy**: Admin - High Security (Tier 3)
- **Authentication**: Google MFA Required
- **Geographic Restriction**: Australia only

### 2. Developer Portal (dev-test.bozza.au)
- **Application Type**: Self-hosted
- **Session Duration**: 8 hours
- **Policy**: Developer - Standard Access (Tier 2)
- **Authentication**: Google MFA Required
- **Geographic Restriction**: Australia only

### 3. Emergency Access (emergency-test.bozza.au)
- **Application Type**: Self-hosted
- **Session Duration**: 1 hour
- **Policy**: Admin - Emergency Access (Tier 4)
- **Authentication**: Google MFA + Justification Required
- **Geographic Restriction**: Australia only

## Testing Instructions

### Test Sequence
1. **Visit each test URL** in different browser sessions/incognito windows
2. **Authenticate via Cloudflare Access** with your Google account
3. **Verify the security policies** are applied correctly
4. **Review the displayed information** for accuracy

### What to Verify

#### Admin Dashboard Test (`admin-test.bozza.au`)
- ✅ Requires Google MFA authentication
- ✅ Shows 2-hour session duration
- ✅ Displays correct user information
- ✅ Shows geographic location (should be Australia)
- ✅ Indicates Tier 3 security level

#### Developer Portal Test (`dev-test.bozza.au`)
- ✅ Requires Google MFA authentication
- ✅ Shows 8-hour session duration
- ✅ Displays developer-focused interface
- ✅ Shows correct group membership
- ✅ Indicates Tier 2 security level

#### Emergency Access Test (`emergency-test.bozza.au`)
- ✅ Requires Google MFA + business justification
- ✅ Shows 1-hour session duration (shortest)
- ✅ Displays emergency warnings
- ✅ Shows enhanced audit information
- ✅ Indicates Tier 4 maximum security

### Access Headers to Monitor
Each Worker displays these Cloudflare Access headers:
- `CF-Access-Authenticated-User-Email`
- `CF-Access-Authenticated-User-Id`  
- `CF-Access-Authenticated-User-Groups`
- `CF-IPCountry`
- `CF-Connecting-IP`

## Troubleshooting

### Common Issues
1. **403 Forbidden**: Access policy not configured or user not in required group
2. **Workers not loading**: DNS records not created or custom domains not configured
3. **Authentication loop**: Access application configuration mismatch
4. **Geographic restriction**: Access from outside Australia will be blocked

### Debugging Steps
1. Check Cloudflare Access logs in **Access** > **Analytics**
2. Verify DNS records are proxied (orange cloud)
3. Confirm Worker is deployed and custom domain is active
4. Test from Australia IP address or temporarily remove geographic restrictions

## Security Validation Checklist

- [ ] All three Workers deploy successfully
- [ ] DNS records created and proxied
- [ ] Access applications configured with correct policies
- [ ] MFA authentication required for all applications
- [ ] Geographic restrictions enforced (Australia only)
- [ ] Session durations correct (1hr, 2hr, 8hr)
- [ ] User groups properly assigned and displayed
- [ ] Audit information accurately captured
- [ ] Emergency access requires justification

## Next Steps

After successful deployment and testing:
1. **Review audit logs** to ensure proper tracking
2. **Fine-tune policies** based on test results
3. **Apply similar configurations** to production applications
4. **Set up monitoring alerts** for security events
5. **Document access procedures** for your team

## File Structure
```
workers/
├── admin-dashboard/
│   ├── index.js
│   └── wrangler.toml
├── developer-portal/
│   ├── index.js
│   └── wrangler.toml
├── emergency-access/
│   ├── index.js
│   └── wrangler.toml
└── DEPLOYMENT_INSTRUCTIONS.md
```
