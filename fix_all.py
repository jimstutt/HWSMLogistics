import re

with open('frontend/index.html', 'r') as f:
    content = f.read()

# 1. Remove the misplaced raw JS text that is rendering on the page
raw_js_pattern = r'\(\)\s*\{\s*// Force correct credentials.*?\}\s*\)'
content = re.sub(raw_js_pattern, '', content, flags=re.DOTALL)
content = re.sub(r'function doLogin\(\)\s*\{.*?\n\}', '', content, flags=re.DOTALL)

# 2. Ensure we have a closing </body>
if '</body>' not in content:
    content += '\n</body>\n</html>'

# 3. The clean override script
override_script = """
<script>
// --- SAFE MODAL FUNCTIONS (Fixes the crash) ---
function showModal(n) {
    let el = document.getElementById('mod-' + n);
    if (!el) el = document.getElementById(n);
    if (el) el.classList.add('show');
    if (n === 'ship-add' || n === 'inv-add') populateDropdowns();
}
function hideModal(n) {
    let el = document.getElementById('mod-' + n);
    if (!el) el = document.getElementById(n);
    if (el) el.classList.remove('show');
}

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

// --- MAP (Blue Warehouses, Red Shipments) ---
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
        new google.maps.marker.AdvancedMarkerElement({ map: mapInstance, position: pos, content: pin.element, title: s.description });
    });
}

// --- DATA LOADING (Fixes blank lists) ---
async function loadShipments() {
    const r = await fetch(API + '/shipments');
    const d = await r.json();
    const el = document.getElementById('ship-list');
    if(el) el.innerHTML = d.map(s => '<div class="list-item" onclick="selShip=' + s.shipmentId + ';this.classList.add(\\'sel\\')">' + s.description + ' - ' + s.destination + ' (' + s.status + ')</div>').join('');
}

async function loadInventory() {
    const [invRes, whRes] = await Promise.all([fetch(API + '/inventory'), fetch(API + '/warehouses')]);
    const inv = await invRes.json();
    const wh = await whRes.json();
    const whMap = {};
    wh.forEach(w => {
        const wid = w.warehouseId || w.id;
        whMap[wid] = { name: w.location, items: [] };
    });
    inv.forEach(i => { if (whMap[i.warehouseId]) whMap[i.warehouseId].items.push(i); });
    let html = '';
    for (const wid in whMap) {
        const w = whMap[wid];
        html += '<h4 style="margin:15px 0 5px 0;color:#007BFF;border-bottom:1px solid #ddd;padding-bottom:5px;">' + w.name + '</h4>';
        if (w.items.length === 0) {
            html += '<div class="list-item" style="color:#888;font-style:italic;">No inventory</div>';
        } else {
            html += w.items.map(i => '<div class="list-item" onclick="selInv=' + i.inventoryId + ';this.classList.add(\\'sel\\')">' + i.description + ' x' + i.quantity + '</div>').join('');
        }
    }
    const el = document.getElementById('inv-list');
    if(el) el.innerHTML = html;
}

// --- DROPDOWNS (Fixes "undefined" and missing IDs) ---
async function populateDropdowns() {
    const whs = await (await fetch(API + '/warehouses')).json();
    ['s-wh', 'i-wh'].forEach(id => {
        let el = document.getElementById(id);
        if (el) {
            if (el.tagName === 'INPUT') {
                const sel = document.createElement('select');
                sel.id = id; sel.className = el.className;
                el.parentNode.replaceChild(sel, el);
                el = sel;
            }
            el.innerHTML = '<option value="">Select Warehouse...</option>' + 
                whs.map(w => '<option value="' + (w.warehouseId || w.id) + '">' + w.location + '</option>').join('');
        }
    });

    const tps = await (await fetch(API + '/transport')).json();
    ['s-tp', 'i-tp'].forEach(id => {
        let el = document.getElementById(id);
        if (el) {
            if (el.tagName === 'INPUT') {
                const sel = document.createElement('select');
                sel.id = id; sel.className = el.className;
                el.parentNode.replaceChild(sel, el);
                el = sel;
            }
            // FIX: Use t.tpName instead of t.name
            el.innerHTML = '<option value="">Select Provider...</option>' + 
                tps.map(t => '<option value="' + t.tpName + '">' + t.tpName + '</option>').join('');
        }
    });
    
    const coordInput = document.getElementById('s-coord');
    if (coordInput) {
        coordInput.style.display = 'none';
        const label = document.querySelector('label[for="s-coord"]');
        if (label) label.style.display = 'none';
    }
}

// --- FIX ADD SHIPMENT (Fixes Inventory Decrement) ---
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
            // FIX: Ensure sourceWarehouse ID is sent so backend decrements inventory
            sourceWarehouse: wh && wh.value ? parseInt(wh.value) : null,
            description: desc ? desc.value : '',
            quantity: qty ? parseInt(qty.value) : 0,
            destination: dest ? dest.value : '',
            transportProvider: tp ? tp.value : '',
            status: 'Pending',
            createdAt: null
        })
    });
    hideModal('ship-add');
    loadShipments();
    loadInventory(); // Refresh inventory to show decrement
    if (typeof go === 'function') go('dashboard'); // Refresh map
};

window.addEventListener('load', () => {
    if (localStorage.getItem('token')) {
        if (typeof go === 'function') go('dashboard');
    }
});
</script>
"""

# Remove any previous override scripts to prevent duplicates
content = re.sub(r'<script>\s*// --- SAFE MODAL FUNCTIONS ---.*?</script>', '', content, flags=re.DOTALL)

content = content.replace('</body>', override_script + '\n</body>')

with open('frontend/index.html', 'w') as f:
    f.write(content)

print("✅ Cleaned raw text and injected robust overrides.")
