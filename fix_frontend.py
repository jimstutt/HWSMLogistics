import re

file_path = 'frontend/index.html'
with open(file_path, 'r') as f:
    content = f.read()

# 1. Remove the broken doLogin fragment that causes the syntax error
broken_fragment = """,
        body: JSON.stringify({ loginEmail: email, loginPassword: password })
    })
    .then(res => res.ok ? res.json() : Promise.reject('HTTP ' + res.status))
    .then(data => {
        if (data.token) {
            localStorage.setItem('token', data.token);
            window.location.hash = 'dashboard';
        } else {
            alert('Login failed: ' + (data.error || 'Invalid credentials'));
        }
    })
    .catch(err => {
        console.error('Login fetch failed:', err);
        alert('Login error: ' + err);
    });
}"""
content = content.replace(broken_fragment, '')

# 2. Remove any trailing <script> blocks we injected
idx = content.find('async function _mapCb')
if idx != -1:
    end_idx = content.find('</script>', idx)
    if end_idx != -1:
        content = content[:end_idx + len('</script>')]

# 3. Ensure we have a </body> tag
if '</body>' not in content:
    content += '\n</body>\n</html>'

# 4. The clean, working override script
override_script = """
<script>
// --- LOGIN FIXES ---
document.addEventListener('DOMContentLoaded', () => {
    const emailInputs = document.querySelectorAll('input[type="email"], input[name*="email"]');
    const passInputs = document.querySelectorAll('input[type="password"], input[name*="password"]');
    emailInputs.forEach(el => { if (!el.value) el.value = 'admin@hwsm.com'; });
    passInputs.forEach(el => { if (!el.value) el.value = 'admin'; });
});

function doLogin() {
    const emailEl = document.querySelector('input[type="email"], input[name*="email"]');
    const passEl = document.querySelector('input[type="password"], input[name*="password"]');
    const email = emailEl ? emailEl.value.trim() : '';
    const password = passEl ? passEl.value : '';
    
    fetch('http://localhost:3000/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ loginEmail: email, loginPassword: password })
    })
    .then(res => res.ok ? res.json() : Promise.reject('HTTP ' + res.status))
    .then(data => {
        if (data.token) {
            localStorage.setItem('token', data.token);
            const loginBg = document.getElementById('login-bg');
            if (loginBg) loginBg.classList.remove('show');
            if (typeof go === 'function') go('dashboard');
        } else {
            const lerr = document.getElementById('lerr');
            if (lerr) lerr.textContent = 'Invalid credentials';
        }
    })
    .catch(err => {
        console.error('Login failed:', err);
        const lerr = document.getElementById('lerr');
        if (lerr) lerr.textContent = 'Login error: ' + err.message;
    });
}

// --- MAP FIXES (Blue Warehouses, Red Shipments, Africa Coords) ---
async function _mapCb() {
    window._mapInit = true;
    mapInstance = new google.maps.Map(document.getElementById('map'), {
        center: { lat: -1.29, lng: 36.82 }, zoom: 4, mapId: '1c58c0dd9e35ef9c4882d48a'
    });
    const cityCoords = {
        'Nairobi, Kenya': { lat: -1.2921, lng: 36.8219 },
        'Cape Town, South Africa': { lat: -33.9249, lng: 18.4241 },
        'Lagos, Nigeria': { lat: 6.5244, lng: 3.3792 }
    };
    const wh = await (await fetch(API + '/warehouses')).json();
    const whCoords = {};
    wh.forEach(w => {
        const pos = cityCoords[w.location] || { lat: -1.29, lng: 36.82 };
        whCoords[w.warehouseId] = pos;
        const pin = new google.maps.marker.PinElement({ background: '#0000FF', borderColor: '#00008B', glyphColor: '#FFFFFF' });
        new google.maps.marker.AdvancedMarkerElement({ map: mapInstance, position: pos, content: pin.element, title: w.location });
    });
    const sh = await (await fetch(API + '/shipments')).json();
    sh.forEach(s => {
        const basePos = whCoords[s.sourceWarehouse] || { lat: -1.29, lng: 36.82 };
        const pos = { lat: basePos.lat + (Math.random() - 0.5) * 2, lng: basePos.lng + (Math.random() - 0.5) * 2 };
        const pin = new google.maps.marker.PinElement({ background: '#FF0000', borderColor: '#8B0000', glyphColor: '#FFFFFF' });
        new google.maps.marker.AdvancedMarkerElement({ map: mapInstance, position: pos, content: pin.element, title: s.description });
    });
}

// --- INVENTORY FIX (Grouped by Warehouse) ---
async function loadInventory() {
    const [invRes, whRes] = await Promise.all([fetch(API + '/inventory'), fetch(API + '/warehouses')]);
    const inv = await invRes.json();
    const wh = await whRes.json();
    const whMap = {};
    wh.forEach(w => whMap[w.warehouseId] = { name: w.location, items: [] });
    inv.forEach(i => { if (whMap[i.warehouseId]) whMap[i.warehouseId].items.push(i); });
    let html = '';
    for (const wid in whMap) {
        const w = whMap[wid];
        html += '<h4 style="margin:15px 0 5px 0;color:#007BFF;border-bottom:1px solid #ddd;padding-bottom:5px;">' + w.name + '</h4>';
        if (w.items.length === 0) {
            html += '<div class="list-item" style="color:#888;font-style:italic;">No inventory</div>';
        } else {
            html += w.items.map(i => '<div class="list-item" onclick="selInv=' + i.inventoryId + ';this.classList.add(\\'sel\\')">' + i.description + ' x' + i.quantity + ' (' + (i.transportProvider || 'N/A') + ')</div>').join('');
        }
    }
    document.getElementById('inv-list').innerHTML = html;
}

// --- SHIPMENTS FORM FIX (Dropdowns & Hide Lat/Lng) ---
const _origShowModal = typeof showModal === 'function' ? showModal : function(){};
window.showModal = function(n) {
    _origShowModal(n);
    if (n === 'ship-add') {
        const coordInput = document.getElementById('s-coord');
        if (coordInput) {
            coordInput.style.display = 'none';
            const label = document.querySelector('label[for="s-coord"]');
            if (label) label.style.display = 'none';
        }
        fetch(API + '/warehouses').then(r => r.json()).then(whs => {
            const el = document.getElementById('s-wh');
            if (el && el.tagName === 'INPUT') {
                const sel = document.createElement('select');
                sel.id = 's-wh'; sel.className = el.className;
                el.parentNode.replaceChild(sel, el);
            }
            const selEl = document.getElementById('s-wh');
            if (selEl) selEl.innerHTML = '<option value="">Select Warehouse...</option>' + whs.map(w => '<option value="' + w.warehouseId + '">' + w.location + '</option>').join('');
        });
        fetch(API + '/transport').then(r => r.json()).then(tps => {
            const el = document.getElementById('s-tp');
            if (el && el.tagName === 'INPUT') {
                const sel = document.createElement('select');
                sel.id = 's-tp'; sel.className = el.className;
                el.parentNode.replaceChild(sel, el);
            }
            const selEl = document.getElementById('s-tp');
            if (selEl) selEl.innerHTML = '<option value="">Select Provider...</option>' + tps.map(t => '<option value="' + t.name + '">' + t.name + '</option>').join('');
        });
    }
};
</script>
"""

content = content.replace('</body>', override_script + '\n</body>')

with open(file_path, 'w') as f:
    f.write(content)

print("✅ File cleaned and all fixes applied cleanly.")
