const fs = require('fs');
const path = require('path');

console.log('🔧 Starting HWSMLogistics automated diagnostics...\n');

// 1. Fix Google Maps in frontend/index.html
const indexPath = path.join(__dirname, 'frontend', 'index.html');
if (fs.existsSync(indexPath)) {
    let html = fs.readFileSync(indexPath, 'utf8');
    
    if (!html.includes('loading=async')) {
        const regex = /(<script\s)(.*?)(src=["']https:\/\/maps\.googleapis\.com\/maps\/api\/js\?)([^"']+)(["'].*?>)/gi;
        
        html = html.replace(regex, (match, p1, p2, p3, params, p5) => {
            let attrs = p2;
            if (!attrs.includes('async')) attrs += 'async ';
            if (!attrs.includes('defer')) attrs += 'defer ';
            
            let newParams = params;
            if (!newParams.includes('loading=async')) {
                newParams += (newParams.endsWith('&') ? '' : '&') + 'loading=async';
            }
            return `${p1}${attrs.trim()}${p3}${newParams}${p5}`;
        });
        
        fs.writeFileSync(indexPath, html, 'utf8');
        console.log('✅ Updated frontend/index.html: Added async/defer to Google Maps.');
    } else {
        console.log('✅ Google Maps script already optimized.');
    }

    // 2. Locate the .split() error
    console.log('\n🔍 Scanning frontend/index.html for .split( ...');
    const lines = html.split('\n');
    lines.forEach((line, idx) => {
        if (line.includes('.split(')) {
            console.log(`   ⚠️ Found at line ${idx + 1}: ${line.trim()}`);
        }
    });
} else {
    console.log('⚠️ frontend/index.html not found!');
}

// 3. Check Backend for CORS
const backendPath = path.join(__dirname, 'Backend', 'server.js');
if (fs.existsSync(backendPath)) {
    let code = fs.readFileSync(backendPath, 'utf8');
    if (!code.includes("require('cors')") && !code.includes('require("cors")')) {
        console.log(`\n⚠️ CORS middleware NOT found in Backend/server.js.`);
        console.log('👉 PLEASE ADD THIS TO THE TOP OF Backend/server.js:');
        console.log('---------------------------------------------------------');
        console.log("const cors = require('cors');");
        console.log("app.use(cors({ origin: 'http://localhost:5173', credentials: true }));");
        console.log('---------------------------------------------------------');
    } else {
        console.log('\n✅ CORS middleware is configured in Backend/server.js.');
    }
} else {
    console.log('\n⚠️ Backend/server.js not found!');
}
