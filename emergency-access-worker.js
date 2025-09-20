// Cloudflare Worker for Emergency Access Test Application
// Domain: emergency-test.bozza.au
// Policy: Admin - Emergency Access (Tier 4)

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
    <title>🚨 Emergency Access - Access Policy Test</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background: linear-gradient(135deg, #dc2626 0%, #991b1b 100%);
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
            border-left: 4px solid #fbbf24;
        }
        .security-info {
            background: rgba(239, 68, 68, 0.3);
            border-radius: 8px;
            padding: 15px;
            margin: 20px 0;
            border: 2px solid rgba(239, 68, 68, 0.5);
        }
        .tier-badge {
            background: #dc2626;
            color: white;
            padding: 8px 20px;
            border-radius: 25px;
            font-size: 14px;
            font-weight: bold;
            display: inline-block;
            margin-bottom: 15px;
            animation: pulse 2s infinite;
        }
        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.7; }
            100% { opacity: 1; }
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
        .emergency-warning {
            background: rgba(245, 101, 101, 0.3);
            border: 2px solid #f87171;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
            text-align: center;
        }
        .audit-info {
            background: rgba(251, 191, 36, 0.2);
            border-radius: 8px;
            padding: 15px;
            margin: 20px 0;
        }
        .session-timer {
            background: rgba(220, 38, 38, 0.4);
            padding: 10px;
            border-radius: 5px;
            text-align: center;
            font-weight: bold;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚨 Emergency Access</h1>
            <div class="tier-badge">TIER 4 - MAXIMUM SECURITY</div>
            <p>Emergency break-glass access activated - all actions are logged!</p>
        </div>
        
        <div class="emergency-warning">
            <h2>⚠️ EMERGENCY ACCESS ACTIVE</h2>
            <p><strong>WARNING:</strong> This is emergency break-glass access with enhanced monitoring.</p>
            <p>All activities are logged and reviewed. Use only for legitimate emergencies.</p>
        </div>
        
        <div class="session-timer">
            ⏰ EMERGENCY SESSION EXPIRES IN: ${new Date(Date.now() + 1*60*60*1000).toLocaleString()}
            <br><small>(1 hour maximum for security)</small>
        </div>
        
        <div class="security-info">
            <h3>🛡️ Emergency Security Policy</h3>
            <ul>
                <li><strong>Policy:</strong> Admin - Emergency Access</li>
                <li><strong>Authentication:</strong> Google MFA Required</li>
                <li><strong>Session Duration:</strong> 1 hour ONLY</li>
                <li><strong>Geographic Restriction:</strong> Australia only</li>
                <li><strong>Group Required:</strong> Admins - Emergency Access</li>
                <li><strong>Justification:</strong> REQUIRED for audit</li>
                <li><strong>Monitoring:</strong> ENHANCED logging active</li>
            </ul>
        </div>
        
        <div class="audit-info">
            <h3>📋 Audit Information</h3>
            <p>This emergency access session is being monitored and recorded:</p>
            <ul>
                <li>🕒 <strong>Access Time:</strong> ${new Date().toLocaleString()}</li>
                <li>👤 <strong>User:</strong> ${userEmail}</li>
                <li>🌍 <strong>Location:</strong> ${userCountry} (${userIP})</li>
                <li>⏱️ <strong>Duration:</strong> Maximum 1 hour</li>
                <li>📝 <strong>Justification:</strong> Required at login</li>
                <li>🔍 <strong>Review Status:</strong> Pending audit review</li>
            </ul>
        </div>
        
        <div class="info-grid">
            <div class="status-card">
                <h4>👤 User Information</h4>
                <p><strong>Email:</strong> ${userEmail}</p>
                <p><strong>User ID:</strong> ${userId.substring(0, 20)}...</p>
                <p><strong>Groups:</strong> ${userGroups}</p>
                <p><strong>Access Level:</strong> Emergency Admin</p>
            </div>
            
            <div class="status-card">
                <h4>🌍 Connection Details</h4>
                <p><strong>IP Address:</strong> ${userIP}</p>
                <p><strong>Country:</strong> ${userCountry}</p>
                <p><strong>Access Method:</strong> Emergency Break-Glass</p>
                <p><strong>Risk Level:</strong> HIGH</p>
            </div>
            
            <div class="status-card">
                <h4>⏰ Session Information</h4>
                <p><strong>Access Time:</strong> ${new Date().toLocaleString()}</p>
                <p><strong>Session Expires:</strong> ${new Date(Date.now() + 1*60*60*1000).toLocaleString()}</p>
                <p><strong>Policy Tier:</strong> 4 (Emergency)</p>
                <p><strong>Auto-logout:</strong> 1 hour</p>
            </div>
            
            <div class="status-card">
                <h4>🔧 Technical Details</h4>
                <p><strong>Worker:</strong> emergency-access-test</p>
                <p><strong>Domain:</strong> ${url.hostname}</p>
                <p><strong>Path:</strong> ${url.pathname}</p>
                <p><strong>Security Level:</strong> Maximum</p>
            </div>
        </div>
        
        <div class="security-info">
            <h4>✅ Emergency Access Verification</h4>
            <p>This emergency session confirms:</p>
            <ul>
                <li>✓ Google MFA was successfully completed</li>
                <li>✓ User is authorized for emergency access</li>
                <li>✓ Business justification was provided</li>
                <li>✓ Request originated from Australia</li>
                <li>✓ Maximum 1-hour session enforced</li>
                <li>✓ Enhanced audit logging active</li>
                <li>✓ All activities monitored and recorded</li>
            </ul>
        </div>
        
        <div class="emergency-warning">
            <h4>📝 Emergency Access Guidelines</h4>
            <p><strong>Remember:</strong></p>
            <ul style="text-align: left;">
                <li>This access is for genuine emergencies only</li>
                <li>Document all actions taken during this session</li>
                <li>Session will automatically expire in 1 hour</li>
                <li>All activities are subject to audit review</li>
                <li>Report completion of emergency activities</li>
            </ul>
        </div>
        
        <footer class="timestamp">
            <p>Emergency Access Test Server | Generated at ${new Date().toISOString()}</p>
            <p><strong>EMERGENCY SESSION ACTIVE - ALL ACTIONS LOGGED</strong></p>
        </footer>
    </div>
</body>
</html>`;
    
    return new Response(html, {
      headers: {
        'Content-Type': 'text/html; charset=UTF-8',
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'X-Frame-Options': 'DENY',
        'X-Content-Type-Options': 'nosniff',
        'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
        'X-Emergency-Access': 'true'
      }
    });
  }
};
