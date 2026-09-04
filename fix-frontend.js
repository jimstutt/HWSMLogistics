const fs = require('fs');
const path = require('path');

const targetFile = path.join(__dirname, 'frontend', 'index.html');

if (!fs.existsSync(targetFile)) {
    console.error(`❌ Error: ${targetFile} not found. Please run this from the project root.`);
    process.exit(1);
}

let html = fs.readFileSync(targetFile, 'utf8');
let originalHtml = html;

// ==========================================
// Fix 1.A: Google Maps Async Loading
// ==========================================
console.log('🔧 Applying Fix 1.A: Google Maps async/defer...');

const mapsRegex = /(<script\b[^>]*\bsrc=["']https:\/\/maps\.googleapis\.com\/maps\/api\/js\?[^"']*["'][^>]*>)/gi;

html = html.replace(mapsRegex, (match) => {
    let tag = match;
    // Add async and defer if missing
    if (!tag.includes('async')) tag = tag.replace('<script', '<script async');
    if (!tag.includes('defer')) tag = tag.replace('async', 'async defer');
    
    // Add loading=async to the URL params if missing
    if (!tag.includes('loading=async')) {
        tag = tag.replace(/(src=["']https:\/\/maps\.googleapis\.com\/maps\/api\/js\?)([^"']*)(["'])/, (m, prefix, params, quote) => {
            const separator = params.endsWith('&') || params.endsWith('?') ? '' : '&';
            return `${prefix}${params}${separator}loading=async${quote}`;
        });
    }
    return tag;
});

// ==========================================
// Fix 1.B: Secure .split() against undefined
// ==========================================
console.log('🔧 Applying Fix 1.B: Securing .split() calls...');

const lines = html.split('\n');
let splitFixCount = 0;

lines.forEach((line, index) => {
    // Look for .split( but ignore empty .split()
    if (line.includes('.split(') && !line.includes('.split()')) {
        // Regex: match variable names (including dot notation like item.location) 
        // but ignore optional chaining (?.) to prevent syntax errors.
        const safeSplitRegex = /(?<!\?)([a-zA-Z0-9_$.]+)\.split\(/g;
        
        // Wrap the variable in a fallback: (variable || '').split(
        const newLine = line.replace(safeSplitRegex, "($1 || '').split(");
        
        if (newLine !== line) {
            lines[index] = newLine;
            splitFixCount++;
            console.log(`   🛡️ Secured .split() at line ${index + 1}`);
            console.log(`      Old: ${line.trim()}`);
            console.log(`      New: ${newLine.trim()}`);
        }
    }
});

html = lines.join('\n');

// ==========================================
// Save and Report
// ==========================================
if (html !== originalHtml) {
    fs.writeFileSync(targetFile, html, 'utf8');
    console.log('\n✅ Successfully updated frontend/index.html!');
    console.log(`   - Google Maps script updated with async/defer/loading=async.`);
    console.log(`   - ${splitFixCount} .split() call(s) secured against undefined values.`);
    console.log('\n💡 Next Step: Restart your frontend dev server to see the changes.');
} else {
    console.log('\nℹ️ No changes were necessary. The file is already up to date.');
}
