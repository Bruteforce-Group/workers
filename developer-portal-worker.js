// Cloudflare Worker for Developer Portal Test Application
// Domain: dev-test.bozza.au
// Policy: Developer - Standard Access (Tier 2)

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    
    // Get Cloudflare Access headers
    const userEmail = request.headers.get('CF-Access-Authenticated-User-Email') || 'Not authenticated';
    const userId = request.headers.get('CF-Access-Authenticated-User-Id') || 'Not authenticated';
    const userGroups = request.headers.get('CF-Access-Authenticated-User-Groups') || 'No groups';
    const userCountry = request.headers.get('CF-IPCountry') || 'Unknown';
    const userIP = request.headers.get('CF-Connecting-IP') || 'Unknown';
    
    // Create the HTML response
    const html = `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>👩‍💻 Developer Portal - Access Policy Test</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
        }
        .container {
            background: rgba(255,255,255,0.1);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 30px;
            border: 1px solid rgba(255,255,255,0.2);
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        .status-card {
            background: rgba(255,255,255,0.1);
            border-radius: 10px;
            padding: 20px;
            margin: 15px 0;
            border-left: 4px solid #60a5fa;
        }
        .security-info {
            background: rgba(59, 130, 246, 0.2);
            border-radius: 8px;
            padding: 15px;
            margin: 20px 0;
        }
        .tier-badge {
            background: #3b82f6;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
            display: inline-block;
            margin-bottom: 10px;
        }
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-top: 20px;
        }
        @media (max-width: 600px) {
            .info-grid { grid-template-columns: 1fr; }
        }
        .timestamp { font-size: 14px; opacity: 0.8; }
        .dev-tools {
            background: rgba(34, 197, 94, 0.2);
            border-radius: 8px;
            padding: 15px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>👩‍💻 Developer Portal</h1>
            <div class="tier-badge">TIER 2 - STANDARD SECURITY</div>
            <p>Welcome to the development environment - authentication successful!</p>
        </div>
        
        <div class="security-info">
            <h3>🛡️ Security Policy Applied</h3>
            <ul>
                <li><strong>Policy:</strong> Developer - Standard Access</li>
                <li><strong>Authentication:</strong> Google MFA Required</li>
                <li><strong>Session Duration:</strong> 8 hours</li>
                <li><strong>Geographic Restriction:</strong> Australia only</li>
                <li><strong>Group Required:</strong> Developers - Standard</li>
            </ul>
        </div>
        
        <div class="dev-tools">
            <h3>🔧 Development Tools Access</h3>
            <p>This tier provides access to:</p>
            <ul>
                <li>✓ Development environments</li>
                <li>✓ Code repositories (GitHub, GitLab)</li>
                <li>✓ Package managers (npm, pip, composer)</li>
                <li>✓ Development documentation</li>
                <li>✓ Staging environments</li>
                <li>✓ Developer APIs and tools</li>
            </ul>
        </div>
        
        <div class="info-grid">
            <div class="status-card">
                <h4>👤 User Information</h4>
                <p><strong>Email:</strong> ${userEmail}</p>
                <p><strong>User ID:</strong> ${userId.substring(0, 20)}...</p>
                <p><strong>Groups:</strong> ${userGroups}</p>
            </div>
            
            <div class="status-card">
                <h4>🌍 Connection Details</h4>
                <p><strong>IP Address:</strong> ${userIP}</p>
                <p><strong>Country:</strong> ${userCountry}</p>
                <p><strong>Access Method:</strong> Cloudflare Access</p>
            </div>
            
            <div class="status-card">
                <h4>⏰ Session Information</h4>
                <p><strong>Access Time:</strong> ${new Date().toLocaleString()}</p>
                <p><strong>Session Expires:</strong> ${new Date(Date.now() + 8*60*60*1000).toLocaleString()}</p>
                <p><strong>Policy Tier:</strong> 2 (Developer)</p>
            </div>
            
            <div class="status-card">
                <h4>🔧 Technical Details</h4>
                <p><strong>Worker:</strong> developer-portal-test</p>
                <p><strong>Domain:</strong> ${url.hostname}</p>
                <p><strong>Path:</strong> ${url.pathname}</p>
            </div>
        </div>
        
        <div class="security-info">
            <h4>✅ Authentication Verification</h4>
            <p>This page confirms that:</p>
            <ul>
                <li>✓ Google MFA was successfully completed</li>
                <li>✓ User has developer-level access</li>
                <li>✓ Request originated from Australia</li>
                <li>✓ Extended 8-hour session for productivity</li>
                <li>✓ Access to development tools and environments</li>
            </ul>
        </div>
        
        <footer class="timestamp">
            <p>Developer Portal Test Server | Generated at ${new Date().toISOString()}</p>
        </footer>
    </div>
</body>
</html>`;
    
    return new Response(html, {
      headers: {
        'Content-Type': 'text/html; charset=UTF-8',
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'X-Frame-Options': 'DENY',
        'X-Content-Type-Options': 'nosniff'
      }
    });
  }
};
