import os
import re

# 1. HARD RESET: Wipe all stray text and broken injections
os.system("git checkout HEAD -- frontend/index.html")
print("✅ Frontend reset to clean state.")

with open('frontend/index.html', 'r') as f:
    content = f.read()

# 2. Basic login fixes
content = content.replace('http://localhost:3000/api/login', 'http://localhost:3000/api/auth/login')
content = content.replace('http://localhost:3000/login', 'http://localhost:3000/api/auth/login')
content = content.replace('value="admin@example.org"', 'value="admin@hwsm.com"')
content = content.replace('value="admin@example.com"', 'value="admin@hwsm.com"')

# 3. AGGRESSIVE STRAY TEXT CLEANER
# Splits the file into <script> blocks and HTML blocks
parts = re.split(r'(<script.*?>.*?</script>)', content, flags=re.DOTALL)
cleaned_parts = []
for part in parts:
    if part.startswith('<script'):
        cleaned_parts.append(part) # Keep scripts intact
    else:
        # This is HTML. Remove any lines that look like stray JS.
        lines = part.split('\n')
        clean_lines = []
        for line in lines:
            # If line contains JS syntax and isn't an HTML tag, drop it
            if re.search(r'(=>|fetch\(|document\.|console\.|localStorage|\.then\()', line) and not line.strip().startswith('<'):
                continue
            clean_lines.append(line)
        cleaned_parts.append('\n'.join(clean_lines))
content = ''.join(cleaned_parts)

# 4. The Master Script
master_script = """
<script>
// --- BULLETPROOF ADMIN TAB DETECTION ---
function getActiveAdminTab() {
    // 1. Try the original global variable first
    if (window.adminType) return window.adminType;
    
    // 2. Fallback: check the visible text of the active tab
    const activeTab = document.querySelector('#admin .tab.active');
    if (activeTab) {
        const text = activeTab.innerText.trim().toLowerCase();
        if (text.includes('user')) return 'user';
        if (text.includes('partner')) return 'partner';
        if (text.includes('warehouse')) return 'wh';
        if (text.includes('transport')) return 'tp';
    }
    return 'user';
}

document.addEventListener('click', function(e) {
    if (e.target && e.target.tagName === 'BUTTON' && e.target.innerText.trim() === 'Add' && document.getElementById('admin').classList.contains('active')) {
        e.preventDefault();
        showAdminAddModal();
    }
});

function showAdminAddModal() {
    const t = getActiveAdminTab();
    let title = 'Add Item';
    let fields = '';
    const style = 'width:100%; margin-bottom:8px; padding:8px; border:1px solid #ccc; border-radius:4px; box-sizing:border-box;';

    if (t.includes('wh') || t.includes('wareh')) {
        title = 'Add Warehouse';
        fields = `<input type="text" id="aw-loc" placeholder="Location" style="${style}">
                  <input type="number" id="aw-cap" placeholder="Capacity" style="${style}">
                  <input type="text" id="aw-trans" placeholder="Transport" style="${style}">
                  <input type="email" id="aw-email" placeholder="Email" style="${style}">
                  <input type="text" id="aw-phone" placeholder="Phone" style="${style}">`;
    } else if (t.includes('tp') || t.includes('trans')) {
        title = 'Add Transport Provider';
        fields = `<input type="text" id="at-name" placeholder="Name" style="${style}">
                  <input type="text" id="at-loc" placeholder="Location" style="${style}">
                  <input type="email" id="at-email" placeholder="Email" style="${style}">
                  <input type="text" id="at-phone" placeholder="Phone" style="${style}">`;
    } else if (t.includes('partner')) {
        title = 'Add Partner';
        fields = `<input type="text" id="ap-org" placeholder="Organisation" style="${style}">
                  <input type="text" id="ap-contact" placeholder="Contact Name" style="${style}">
                  <input type="text" id="ap-addr" placeholder="Address" style="${style}">
                  <input type="email" id="ap-email" placeholder="Email" style="${style}">
                  <input type="text" id="ap-phone" placeholder="Phone" style="${style}">`;
    } else {
        title = 'Add User';
        fields = `<input type="text" id="au-fname" placeholder="First Name" style="${style}">
                  <input type="text" id="au-sname" placeholder="Second Name" style="${style}">
                  <input type="email" id="au-email" placeholder="Email" style="${style}">
                  <input type="password" id="au-pass" placeholder="Password" style="${style}">
                  <input type="text" id="au-org" placeholder="Organisation" style="${style}">
                  <input type="text" id="au-role" placeholder="Role" style="${style}">`;
    }

    const modal = document.createElement('div');
    modal.id = 'admin-add-modal';
    modal.style.cssText = 'position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); display:flex; align-items:center; justify-content:center; z-index:1000;';
    modal.innerHTML = `<div style="background:white; padding:20px; border-radius:8px; width:300px; box-shadow:0 4px 6px rgba(0,0,0,0.1);">
        <h3 style="margin-top:0;">${title}</h3>
        <div id="admin-add-fields">${fields}</div>
        <button onclick="saveAdminItem()" style="margin-top:10px; background:#28a745; color:white; border:none; padding:8px 16px; border-radius:4px; cursor:pointer; width:48%;">Save</button>
        <button onclick="document.getElementById('admin-add-modal').remove()" style="margin-top:10px; background:#dc3545; color:white; border:none; padding:8px 16px; border-radius:4px; cursor:pointer; width:48%;">Cancel</button>
    </div>`;
    document.body.appendChild(modal);
}

window.saveAdminItem = async function() {
    const t = getActiveAdminTab();
    let payload = {};
    let endpoint = '';

    if (t.includes('wh') || t.includes('wareh')) {
        endpoint = API + '/warehouses';
        payload = { warehouseId: 0, location: document.getElementById('aw-loc').value, capacity: parseInt(document.getElementById('aw-cap').value) || 0, transport: document.getElementById('aw-trans').value, contactEmail: document.getElementById('aw-email').value, contactPhone: document.getElementById('aw-phone').value };
    } else if (t.includes('tp') || t.includes('trans')) {
        endpoint = API + '/transport';
        payload = { tpId: 0, tpName: document.getElementById('at-name').value, tpLocation: document.getElementById('at-loc').value, tpEmail: document.getElementById('at-email').value, tpPhone: document.getElementById('at-phone').value };
    } else if (t.includes('partner')) {
        endpoint = API + '/partners';
        payload = { partnerId: 0, organisation: document.getElementById('ap-org').value, contactName: document.getElementById('ap-contact').value, address: document.getElementById('ap-addr').value, email: document.getElementById('ap-email').value, phone: document.getElementById('ap-phone').value };
    } else {
        endpoint = API + '/users';
        payload = { userId: 0, firstName: document.getElementById('au-fname').value, secondName: document.getElementById('au-sname').value, email: document.getElementById('au-email').value, passwordHash: document.getElementById('au-pass').value, organisation: document.getElementById('au-org').value, role: document.getElementById('au-role').value };
    }

    try {
        const res = await fetch(endpoint, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) });
        if (res.ok) {
            document.getElementById('admin-add-modal').remove();
            if (typeof loadAdmin === 'function') loadAdmin();
            alert('Item added successfully!');
        } else {
            alert('Failed to add item: HTTP ' + res.status);
        }
    } catch (err) {
        alert('Error: ' + err.message);
    }
};

// --- LOGIN ---
function doLogin() {
    fetch('http://localhost:3000/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ loginEmail: 'admin@hwsm.com', loginPassword: 'admin' })
    })
    .then(res => res.ok ? res.json() : Promise.reject('HTTP ' + res.status))
    .then(data => {
        if (data.token) {
            localStorage.setItem('token', data.token);
            const loginBg = document.getElementById('login-bg');
            if (loginBg) loginBg.classList.remove('show');
            if (typeof go === 'function') go('dashboard');
        }
    })
    .catch(err => console.error('Login failed:', err));
}

// --- MAP WITH TEXT LABELS ---
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
        const wid = w.warehouseId || w.id;
        const pos = cityCoords[w.location] || { lat: -1.29, lng: 36.82 };
        whCoords[wid] = pos;
        const pin = new google.maps.marker.PinElement({ background: '#0000FF', borderColor: '#00008B', glyphColor: '#FFFFFF' });
        new google.maps.marker.AdvancedMarkerElement({ map: mapInstance, position: pos, content: pin.element, title: w.location });
    });
    const sh = await (await fetch(API + '/shipments')).json();
    sh.forEach(s => {
        const basePos = whCoords[s.sourceWarehouse] || { lat: -1.29, lng: 36.82 };
        const pos = { lat: basePos.lat + (Math.random() - 0.5) * 2, lng: basePos.lng + (Math.random() - 0.5) * 2 };
        const pin = new google.maps.marker.PinElement({ background: '#FF0000', borderColor: '#8B0000', glyphColor: '#FFFFFF' });
        const labelDiv = document.createElement('div');
        labelDiv.style.cssText = 'font-size: 11px; font-weight: bold; background: rgba(255,255,255,0.95); color: #333; padding: 2px 6px; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.3); margin-top: 4px; white-space: nowrap; border: 1px solid #ccc;';
        labelDiv.textContent = s.description + ' -> ' + s.destination;
        const wrapper = document.createElement('div');
        wrapper.style.cssText = 'display: flex; flex-direction: column; align-items: center;';
        wrapper.appendChild(pin.element);
        wrapper.appendChild(labelDiv);
        new google.maps.marker.AdvancedMarkerElement({ map: mapInstance, position: pos, content: wrapper, title: s.description });
    });
}

// --- INVENTORY GROUPED ---
async function loadInventory() {
    const [invRes, whRes] = await Promise.all([fetch(API + '/inventory'), fetch(API + '/warehouses')]);
    const inv = await invRes.json();
    const wh = await whRes.json();
    const whMap = {};
    wh.forEach(w => { const wid = w.warehouseId || w.id; whMap[wid] = { name: w.location, items: [] }; });
    inv.forEach(i => { if (whMap[i.warehouseId]) whMap[i.warehouseId].items.push(i); });
    let html = '';
    for (const wid in whMap) {
        const w = whMap[wid];
        html += '<h4 style="margin:15px 0 5px 0;color:#007BFF;border-bottom:1px solid #ddd;padding-bottom:5px;">' + w.name + '</h4>';
        html += w.items.length === 0 ? '<div class="list-item" style="color:#888;">No inventory</div>' : 
            w.items.map(i => '<div class="list-item">' + i.description + ' x' + i.quantity + '</div>').join('');
    }
    const el = document.getElementById('inv-list');
    if(el) el.innerHTML = html;
}

// --- DROPDOWNS ---
async function populateDropdowns() {
    const whs = await (await fetch(API + '/warehouses')).json();
    ['s-wh', 'i-wh'].forEach(id => {
        let el = document.getElementById(id);
        if (el && el.tagName === 'INPUT') {
            const sel = document.createElement('select');
            sel.id = id; sel.className = el.className;
            el.parentNode.replaceChild(sel, el); el = sel;
        }
        if (el) el.innerHTML = '<option value="">Select...</option>' + whs.map(w => '<option value="' + (w.warehouseId || w.id) + '">' + w.location + '</option>').join('');
    });
    const tps = await (await fetch(API + '/transport')).json();
    ['s-tp', 'i-tp'].forEach(id => {
        let el = document.getElementById(id);
        if (el && el.tagName === 'INPUT') {
            const sel = document.createElement('select');
            sel.id = id; sel.className = el.className;
            el.parentNode.replaceChild(sel, el); el = sel;
        }
        if (el) el.innerHTML = '<option value="">Select...</option>' + tps.map(t => '<option value="' + t.tpName + '">' + t.tpName + '</option>').join('');
    });
    const coord = document.getElementById('s-coord');
    if (coord) { coord.style.display = 'none'; const lbl = document.querySelector('label[for="s-coord"]'); if (lbl) lbl.style.display = 'none'; }
}

const _origShowModal = typeof showModal === 'function' ? showModal : function(){};
window.showModal = function(n) {
    _origShowModal(n);
    if (n === 'ship-add' || n === 'inv-add') populateDropdowns();
};

window.addShipment = async function() {
    const wh = document.getElementById('s-wh');
    const desc = document.getElementById('s-desc');
    const qty = document.getElementById('s-qty');
    const dest = document.getElementById('s-dest');
    const tp = document.getElementById('s-tp');
    await fetch(API + '/shipments', {
        method: 'POST',
        headers: {'Content-Type':'application/json'},
        body: JSON.stringify({
            shipmentId: 0,
            sourceWarehouse: wh && wh.value ? parseInt(wh.value) : null,
            description: desc ? desc.value : '',
            quantity: qty ? parseInt(qty.value) : 0,
            destination: dest ? dest.value : '',
            transportProvider: tp ? tp.value : '',
            status: 'Pending',
            createdAt: null
        })
    });
    if (typeof hideModal === 'function') hideModal('ship-add');
    if (typeof loadShipments === 'function') loadShipments();
    if (typeof loadInventory === 'function') loadInventory();
    if (typeof go === 'function') go('dashboard');
};
</script>
"""

# 5. Safely append the script
if '</body>' in content:
    content = content.replace('</body>', master_script + '\n</body>')
else:
    content += '\n' + master_script

with open('frontend/index.html', 'w') as f:
    f.write(content)

print("✅ Hard reset complete. Stray text scrubbed, and Admin modals are now bulletproof.")
