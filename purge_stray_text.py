import re

with open('frontend/index.html', 'r') as f:
    content = f.read()

# 1. Remove the specific known stray text block from earlier
stray_text = """}) .then(res => { if (res.ok) return res.json(); throw new Error('HTTP ' + res.status); }) .then(data => { if (data.token) { console.log('✅ Login successful!'); localStorage.setItem('token', data.token); const loginBg = document.getElementById('login-bg'); if (loginBg) loginBg.classList.remove('show'); if (typeof go === 'function') go('dashboard'); } else { const lerr = document.getElementById('lerr'); if (lerr) lerr.textContent = 'Invalid credentials'; } }) .catch(err => { console.error('❌ Login failed:', err); const lerr = document.getElementById('lerr'); if (lerr) lerr.textContent = 'Login error: ' + err.message; }); }"""
content = content.replace(stray_text, '')

# 2. General cleanup: Split file into <script> blocks and HTML blocks
parts = re.split(r'(<script.*?>.*?</script>)', content, flags=re.DOTALL)
new_parts = []

for part in parts:
    if part.startswith('<script'):
        # Keep script blocks exactly as they are
        new_parts.append(part)
    else:
        # This is HTML/text outside of scripts. Remove any lines containing JS syntax.
        lines = part.split('\n')
        clean_lines = []
        for line in lines:
            # If the line has JS keywords and isn't an HTML tag, drop it
            if re.search(r'(=>|fetch\(|document\.|console\.|localStorage)', line) and not line.strip().startswith('<'):
                continue
            clean_lines.append(line)
        new_parts.append('\n'.join(clean_lines))

content = ''.join(new_parts)

# 3. Ensure admin.js is linked at the bottom
if '<script src="admin.js"></script>' not in content:
    content = content.replace('</body>', '<script src="admin.js"></script>\n</body>')

with open('frontend/index.html', 'w') as f:
    f.write(content)

print("✅ Stray text completely purged from index.html.")
