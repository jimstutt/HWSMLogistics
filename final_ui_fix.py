import os

# 1. Hard reset to completely wipe any splattered raw text
os.system("git checkout HEAD -- frontend/index.html")
print("✅ Frontend reset to clean state.")

with open('frontend/index.html', 'r') as f:
    content = f.read()

# 2. Fix login URL and pre-fill credentials
content = content.replace('http://localhost:3000/api/login', 'http://localhost:3000/api/auth/login')
content = content.replace('value="admin@example.org"', 'value="admin@hwsm.com"')
content = content.replace('value="admin@example.com"', 'value="admin@hwsm.com"')

# 3. The Master Override Script (Includes Text Labels for Markers)
master_script = """
<script>
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

// --- MODALS & DROPDOWNS ---
window.showModal = function(n) {
    let el = document.getElementById('mod-' + n) || document.getElementById(n);
    if (el) el.classList.add('show');
    if (n === 'ship-add' || n === 'inv-add') populateDropdowns();
};
window.hideModal = function(n) {
    let el = document.getElementById('mod-' + n) || document.getElementById(n);
    if (el) el.classList.remove('show');
};

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
    
    // Blue Warehouse Markers
    const wh = await (await fetch(API + '/warehouses')).json();
    const whCoords = {};
    wh.forEach(w => {
        const wid = w.warehouseId || w.id;
        const pos = cityCoords[w.location] || { lat: -1.29, lng: 36.82 };
        whCoords[wid] = pos;
        const pin = new google.maps.marker.PinElement({ background: '#0000FF', borderColor: '#00008B', glyphColor: '#FFFFFF' });
        new google.maps.marker.AdvancedMarkerElement({ map: mapInstance, position: pos, content: pin.element, title: w.location });
    });
    
    // Red Shipment Markers WITH TEXT TAGS
    const sh = await (await fetch(API + '/shipments')).json();
    sh.forEach(s => {
        const basePos = whCoords[s.sourceWarehouse] || { lat: -1.29, lng: 36.82 };
        const pos = { lat: basePos.lat + (Math.random() - 0.5) * 2, lng: basePos.lng + (Math.random() - 0.5) * 2 };
        
        const pin = new google.maps.marker.PinElement({ background: '#FF0000', borderColor: '#8B0000', glyphColor: '#FFFFFF' });
        
        // Create the persistent text tag below the pin
        const labelDiv = document.createElement('div');
        labelDiv.style.cssText = 'font-size: 11px; font-weight: bold; background: rgba(255,255,255,0.95); color: #333; padding: 2px 6px; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.3); margin-top: 4px; white-space: nowrap; border: 1px solid #ccc;';
        labelDiv.textContent = s.description + ' -> ' + s.destination;
        
        // Wrap pin and text together
        const wrapper = document.createElement('div');
        wrapper.style.cssText = 'display: flex; flex-direction: column; align-items: center;';
        wrapper.appendChild(pin.element);
        wrapper.appendChild(labelDiv);

        new google.maps.marker.AdvancedMarkerElement({
            map: mapInstance,
            position: pos,
            content: wrapper,
            title: s.description
        });
    });
}

// --- DATA LOADING & ADD SHIPMENT ---
async function loadShipments() {
    const r = await fetch(API + '/shipments');
    const d = await r.json();
    const el = document.getElementById('ship-list');
    if(el) el.innerHTML = d.map(s => '<div class="list-item">' + s.description + ' - ' + s.destination + ' (' + s.status + ')</div>').join('');
}

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

# 4. Safely append the script
if '</body>' in content:
    content = content.replace('</body>', master_script + '\n</body>')
else:
    content += '\n' + master_script

with open('frontend/index.html', 'w') as f:
    f.write(content)

print("✅ Splattered text wiped, and map markers now include persistent text tags!")
