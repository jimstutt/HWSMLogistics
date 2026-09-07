html_content = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HWSM Logistics</title>
    <style>
        * { box-sizing: border-box; }
        body { display: flex; height: 100vh; margin: 0; font-family: Arial, sans-serif; background: #f4f4f9; }
        #sidebar { width: 220px; background: #2c3e50; color: white; display: flex; flex-direction: column; flex-shrink: 0; }
        #sidebar h2 { text-align: center; padding: 20px 0; margin: 0; border-bottom: 1px solid #34495e; font-size: 1.2rem; }
        #sidebar a { color: #ecf0f1; text-decoration: none; padding: 15px 20px; display: block; cursor: pointer; transition: background 0.2s; }
        #sidebar a:hover, #sidebar a.active { background: #34495e; border-left: 4px solid #3498db; }
        #sidebar .ws-status { text-align: center; padding: 10px; font-size: 0.8rem; color: #e74c3c; margin-top: auto; }
        #sidebar .login-btn { padding: 15px 20px; background: #27ae60; text-align: center; font-weight: bold; cursor: pointer; }
        #sidebar .login-btn:hover { background: #2ecc71; }
        #main-content { flex: 1; padding: 20px; overflow-y: auto; }
        .page { display: none; }
        .page.active { display: block; }
        #shipments-container { display: flex; gap: 20px; height: calc(100vh - 80px); }
        .half-panel { flex: 1; background: white; padding: 15px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); display: flex; flex-direction: column; }
        .panel-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; padding-bottom: 10px; border-bottom: 2px solid #ecf0f1; }
        .panel-header h3 { margin: 0; color: #2c3e50; }
        .list-container { flex: 1; overflow-y: auto; }
        .btn { padding: 6px 12px; background: #3498db; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 0.9rem; }
        .btn-danger { background: #e74c3c; }
        .btn-success { background: #2ecc71; }
        .list-item { background: #f8f9fa; padding: 10px; margin-bottom: 8px; border-radius: 4px; border-left: 4px solid #3498db; cursor: pointer; font-size: 0.9rem; }
        .list-item:hover { background: #e9ecef; }
        #map { height: calc(100vh - 80px); width: 100%; background: #ddd; border-radius: 8px; }
        .tab-container { display: flex; gap: 5px; margin-bottom: 15px; }
        .tab { padding: 8px 16px; background: #bdc3c7; cursor: pointer; border-radius: 4px 4px 0 0; font-size: 0.9rem; }
        .tab.active { background: #3498db; color: white; }
        .tab-content { background: white; padding: 20px; border-radius: 0 4px 4px 4px; min-height: 300px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); z-index: 1000; align-items: center; justify-content: center; }
        .modal.show { display: flex; }
        .modal-content { background: white; padding: 20px; border-radius: 8px; width: 320px; box-shadow: 0 4px 15px rgba(0,0,0,0.2); }
        .modal-content h3 { margin-top: 0; color: #2c3e50; }
        .modal-content input, .modal-content select { width: 100%; margin-bottom: 12px; padding: 8px; border: 1px solid #ccc; border-radius: 4px; }
        .modal-actions { display: flex; gap: 10px; margin-top: 15px; }
        .modal-actions button { flex: 1; }
        .reports-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; }
        .report-card { background: white; padding: 20px; border-radius: 8px; text-align: center; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .report-card h3 { font-size: 2.5rem; margin: 0; color: #3498db; }
        .report-card p { color: #7f8c8d; margin: 5px 0 0 0; }
    </style>
</head>
<body>
<div id="sidebar">
    <h2>HWSM Logistics</h2>
    <a onclick="go('dashboard')" id="nav-dashboard" class="active">Dashboard</a>
    <a onclick="go('shipments')" id="nav-shipments">Shipments & Inventory</a>
    <a onclick="go('reports')" id="nav-reports">Reports</a>
    <a onclick="go('admin')" id="nav-admin">Admin</a>
    <div id="ws-status" class="ws-status">WS: Disconnected</div>
    <div class="login-btn" onclick="document.getElementById('login-bg').classList.add('show')">Login</div>
</div>
<div id="main-content">
    <div id="dashboard" class="page active"><h2>Dashboard</h2><div id="map"></div></div>
    <div id="shipments" class="page">
        <div id="shipments-container">
            <div class="half-panel">
                <div class="panel-header"><h3>Shipments</h3><div><button class="btn btn-success" onclick="showModal('ship-add')">Add</button><button class="btn" onclick="loadShipments()">Refresh</button></div></div>
                <div id="ship-list" class="list-container"></div>
            </div>
            <div class="half-panel">
                <div class="panel-header"><h3>Inventory</h3><div><button class="btn btn-success" onclick="showModal('inv-add')">Add</button><button class="btn" onclick="loadInventory()">Refresh</button></div></div>
                <div id="inv-list" class="list-container"></div>
            </div>
        </div>
    </div>
    <div id="reports" class="page">
        <h2>Reports</h2>
        <div class="reports-grid">
            <div class="report-card"><h3 id="rep-ship">0</h3><p>Total Shipments</p></div>
            <div class="report-card"><h3 id="rep-inv">0</h3><p>Inventory Items</p></div>
            <div class="report-card"><h3 id="rep-wh">0</h3><p>Warehouses</p></div>
            <div class="report-card"><h3 id="rep-part">0</h3><p>Partners</p></div>
        </div>
    </div>
    <div id="admin" class="page">
        <h2>Admin</h2>
        <div class="tab-container">
            <span class="tab active" onclick="adminTab('user')">Users</span>
            <span class="tab" onclick="adminTab('partner')">Partners</span>
            <span class="tab" onclick="adminTab('wh')">Warehouses</span>
            <span class="tab" onclick="adminTab('tp')">Transport</span>
        </div>
        <div class="tab-content">
            <div style="display: flex; justify-content: space-between; margin-bottom: 15px;">
                <button class="btn" onclick="loadAdmin()">Refresh</button>
                <button class="btn btn-success" onclick="showCustomAdminAdd()">Add</button>
            </div>
            <div id="admin-list" class="list-container"></div>
        </div>
    </div>
</div>
<div id="login-bg" class="modal show">
    <div class="modal-content">
        <h3>Login</h3>
        <input type="email" id="lemail" placeholder="Email" value="admin@hwsm.com">
        <input type="password" id="lpass" placeholder="Password" value="admin">
        <p id="lerr" style="color: red; font-size: 12px; margin-top: -5px;"></p>
        <div class="modal-actions"><button class="btn btn-success" onclick="doLogin()">Login</button><button class="btn btn-danger" onclick="document.getElementById('login-bg').classList.remove('show')">Cancel</button></div>
    </div>
</div>
<div id="mod-ship-add" class="modal">
    <div class="modal-content">
        <h3>Add Shipment</h3>
        <input type="text" id="s-wh" placeholder="Warehouse">
        <input type="text" id="s-desc" placeholder="Description">
        <input type="number" id="s-qty" placeholder="Quantity">
        <input type="text" id="s-dest" placeholder="Destination">
        <input type="text" id="s-tp" placeholder="Transport Provider">
        <input type="text" id="s-coord" placeholder="Coordinates (Lat, Lng)" style="display:none;">
        <div class="modal-actions"><button class="btn btn-success" onclick="addShipment()">Save</button><button class="btn btn-danger" onclick="hideModal('ship-add')">Cancel</button></div>
    </div>
</div>
<div id="mod-inv-add" class="modal">
    <div class="modal-content">
        <h3>Add Inventory</h3>
        <input type="text" id="i-wh" placeholder="Warehouse">
        <select id="i-desc"><option value="Food">Food</option><option value="Water">Water</option><option value="Medical">Medical</option><option value="Sanitary">Sanitary</option><option value="Clothing">Clothing</option><option value="Bedding">Bedding</option><option value="Shelter">Shelter</option></select>
        <input type="number" id="i-qty" placeholder="Quantity">
        <input type="text" id="i-tp" placeholder="Transport Provider">
        <div class="modal-actions"><button class="btn btn-success" onclick="addInventory()">Save</button><button class="btn btn-danger" onclick="hideModal('inv-add')">Cancel</button></div>
    </div>
</div>
<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyDW_1yxgCrgZTESXigHmVFLSp398EGgb6I&callback=_mapCb&libraries=marker&loading=async" async defer></script>
<script>
const API = 'http://localhost:3000/api';
let mapInstance = null;
let adminType = 'user';

function doLogin() {
    const email = document.getElementById('lemail').value;
    const pass = document.getElementById('lpass').value;
    fetch(API + '/auth/login', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ loginEmail: email, loginPassword: pass }) })
    .then(res => res.ok ? res.json() : Promise.reject('HTTP ' + res.status))
    .then(data => {
        if (data.token) {
            localStorage.setItem('token', data.token);
            document.getElementById('login-bg').classList.remove('show');
            connectWebSocket();
            go('dashboard');
        } else { document.getElementById('lerr').textContent = 'Invalid credentials'; }
    })
    .catch(err => { console.error('Login failed:', err); document.getElementById('lerr').textContent = 'Login error: ' + err; });
}

function go(page) {
    document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
    document.getElementById(page).classList.add('active');
    document.querySelectorAll('#sidebar a').forEach(a => a.classList.remove('active'));
    const navLink = document.getElementById('nav-' + page);
    if (navLink) navLink.classList.add('active');
    if (page === 'dashboard' && typeof _mapCb === 'function') _mapCb();
    if (page === 'shipments') { loadShipments(); loadInventory(); }
    if (page === 'reports') loadReports();
    if (page === 'admin') loadAdmin();
}

function showModal(id) { document.getElementById('mod-' + id).classList.add('show'); if (id === 'ship-add' || id === 'inv-add') populateDropdowns(); }
function hideModal(id) { document.getElementById('mod-' + id).classList.remove('show'); }

function adminTab(t) {
    adminType = t;
    document.querySelectorAll('#admin .tab').forEach(tab => tab.classList.remove('active'));
    event.target.classList.add('active');
    loadAdmin();
}

async function loadAdmin() {
    let endpoint = API + '/' + (adminType === 'wh' ? 'warehouses' : adminType === 'tp' ? 'transport' : adminType + 's');
    try {
        const res = await fetch(endpoint);
        const data = await res.json();
        const listEl = document.getElementById('admin-list');
        listEl.innerHTML = data.map(item => {
            let id = item.userId || item.partnerId || item.warehouseId || item.tpId || item.id;
            let type = adminType === 'wh' ? 'warehouses' : adminType === 'tp' ? 'transport' : adminType + 's';
            let text = '';
            if (adminType === 'user') text = item.firstName + ' ' + item.secondName + ' (' + item.email + ')';
            else if (adminType === 'partner') text = item.organisation + ' - ' + item.contactName;
            else if (adminType === 'wh') text = item.location + ' (Cap: ' + item.capacity + ')';
            else if (adminType === 'tp') text = item.tpName + ' (' + item.tpLocation + ')';
            else text = 'Item';
            return '<div class="list-item">' + text + ' <button class="btn btn-danger" style="float:right; padding: 2px 8px; font-size: 0.8rem;" onclick="deleteItem(\\'' + type + '\\',' + id + ')">Remove</button></div>';
        }).join('');
    } catch (err) { console.error(err); }
}

function showCustomAdminAdd() {
    let title = 'Add Item', fields = '';
    const s = 'width:100%; margin-bottom:8px; padding:8px; border:1px solid #ccc; border-radius:4px; box-sizing:border-box;';
    if (adminType === 'wh') { title = 'Add Warehouse'; fields = '<input type="text" id="aw-loc" placeholder="Location" style="'+s+'"><input type="number" id="aw-cap" placeholder="Capacity" style="'+s+'"><input type="text" id="aw-trans" placeholder="Transport" style="'+s+'"><input type="email" id="aw-email" placeholder="Email" style="'+s+'"><input type="text" id="aw-phone" placeholder="Phone" style="'+s+'">'; }
    else if (adminType === 'tp') { title = 'Add Transport Provider'; fields = '<input type="text" id="at-name" placeholder="Name" style="'+s+'"><input type="text" id="at-loc" placeholder="Location" style="'+s+'"><input type="email" id="at-email" placeholder="Email" style="'+s+'"><input type="text" id="at-phone" placeholder="Phone" style="'+s+'">'; }
    else if (adminType === 'partner') { title = 'Add Partner'; fields = '<input type="text" id="ap-org" placeholder="Organisation" style="'+s+'"><input type="text" id="ap-contact" placeholder="Contact Name" style="'+s+'"><input type="text" id="ap-addr" placeholder="Address" style="'+s+'"><input type="email" id="ap-email" placeholder="Email" style="'+s+'"><input type="text" id="ap-phone" placeholder="Phone" style="'+s+'">'; }
    else { title = 'Add User'; fields = '<input type="text" id="au-fname" placeholder="First Name" style="'+s+'"><input type="text" id="au-sname" placeholder="Second Name" style="'+s+'"><input type="email" id="au-email" placeholder="Email" style="'+s+'"><input type="password" id="au-pass" placeholder="Password" style="'+s+'"><input type="text" id="au-org" placeholder="Organisation" style="'+s+'"><input type="text" id="au-role" placeholder="Role" style="'+s+'">'; }
    const existing = document.getElementById('custom-admin-modal');
    if (existing) existing.remove();
    const modal = document.createElement('div');
    modal.id = 'custom-admin-modal';
    modal.style.cssText = 'position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); display:flex; align-items:center; justify-content:center; z-index:9999;';
    modal.innerHTML = '<div style="background:white; padding:20px; border-radius:8px; width:320px; box-shadow:0 4px 6px rgba(0,0,0,0.1);"><h3 style="margin-top:0;">' + title + '</h3><div id="custom-admin-fields">' + fields + '</div><div class="modal-actions"><button onclick="saveCustomAdminItem()" class="btn btn-success">Save</button><button onclick="document.getElementById(\\'custom-admin-modal\\').remove()" class="btn btn-danger">Cancel</button></div></div>';
    document.body.appendChild(modal);
}

window.saveCustomAdminItem = async function() {
    let payload = {}, endpoint = API + '/';
    if (adminType === 'wh') { endpoint += 'warehouses'; payload = { warehouseId: 0, location: document.getElementById('aw-loc').value, capacity: parseInt(document.getElementById('aw-cap').value)||0, transport: document.getElementById('aw-trans').value, contactEmail: document.getElementById('aw-email').value, contactPhone: document.getElementById('aw-phone').value }; }
    else if (adminType === 'tp') { endpoint += 'transport'; payload = { tpId: 0, tpName: document.getElementById('at-name').value, tpLocation: document.getElementById('at-loc').value, tpEmail: document.getElementById('at-email').value, tpPhone: document.getElementById('at-phone').value }; }
    else if (adminType === 'partner') { endpoint += 'partners'; payload = { partnerId: 0, organisation: document.getElementById('ap-org').value, contactName: document.getElementById('ap-contact').value, address: document.getElementById('ap-addr').value, email: document.getElementById('ap-email').value, phone: document.getElementById('ap-phone').value }; }
    else { endpoint += 'users'; payload = { userId: 0, firstName: document.getElementById('au-fname').value, secondName: document.getElementById('au-sname').value, email: document.getElementById('au-email').value, passwordHash: document.getElementById('au-pass').value, organisation: document.getElementById('au-org').value, role: document.getElementById('au-role').value }; }
    try {
        const res = await fetch(endpoint, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) });
        if (res.ok) { document.getElementById('custom-admin-modal').remove(); loadAdmin(); alert('Added successfully!'); }
        else { alert('Failed: ' + await res.text()); }
    } catch (err) { alert('Error: ' + err.message); }
};

window.deleteItem = async function(type, id) { if(!confirm('Are you sure?')) return; const res = await fetch(API + '/' + type + '/' + id, { method: 'DELETE' }); if(res.ok) loadAdmin(); else alert('Delete failed: ' + await res.text()); };
window.deleteShipment = async function(id) { if(!confirm('Are you sure?')) return; const res = await fetch(API + '/shipments/' + id, { method: 'DELETE' }); if(res.ok) loadShipments(); else alert('Delete failed: ' + await res.text()); };
window.deleteInventory = async function(id) { if(!confirm('Are you sure?')) return; const res = await fetch(API + '/inventory/' + id, { method: 'DELETE' }); if(res.ok) loadInventory(); else alert('Delete failed: ' + await res.text()); };

async function loadShipments() {
    const r = await fetch(API + '/shipments'); const d = await r.json();
    document.getElementById('ship-list').innerHTML = d.map(s => '<div class="list-item">' + s.description + ' -> ' + s.destination + ' (' + s.status + ') <button class="btn btn-danger" style="float:right; padding: 2px 8px; font-size: 0.8rem;" onclick="deleteShipment(' + s.shipmentId + ')">Remove</button></div>').join('');
}

async function loadInventory() {
    const [invRes, whRes] = await Promise.all([fetch(API + '/inventory'), fetch(API + '/warehouses')]);
    const inv = await invRes.json(); const wh = await whRes.json();
    const whMap = {};
    wh.forEach(w => { const wid = w.warehouseId || w.id; whMap[wid] = { name: w.location, items: [] }; });
    inv.forEach(i => { if (whMap[i.warehouseId]) whMap[i.warehouseId].items.push(i); });
    let html = '';
    for (const wid in whMap) {
        const w = whMap[wid];
        html += '<h4 style="margin:15px 0 5px 0;color:#007BFF;border-bottom:1px solid #ddd;padding-bottom:5px;">' + w.name + '</h4>';
        html += w.items.length === 0 ? '<div class="list-item" style="color:#888;">No inventory</div>' : w.items.map(i => '<div class="list-item">' + i.description + ' x' + i.quantity + ' <button class="btn btn-danger" style="float:right; padding: 2px 8px; font-size: 0.8rem;" onclick="deleteInventory(' + i.inventoryId + ')">Remove</button></div>').join('');
    }
    document.getElementById('inv-list').innerHTML = html;
}

async function loadReports() {
    const s = await (await fetch(API + '/shipments')).json(); const i = await (await fetch(API + '/inventory')).json();
    const w = await (await fetch(API + '/warehouses')).json(); const p = await (await fetch(API + '/partners')).json();
    document.getElementById('rep-ship').innerText = s.length; document.getElementById('rep-inv').innerText = i.length;
    document.getElementById('rep-wh').innerText = w.length; document.getElementById('rep-part').innerText = p.length;
}

async function populateDropdowns() {
    const whs = await (await fetch(API + '/warehouses')).json();
    ['s-wh', 'i-wh'].forEach(id => {
        let el = document.getElementById(id);
        if (el && el.tagName === 'INPUT') { const sel = document.createElement('select'); sel.id = id; sel.className = el.className; el.parentNode.replaceChild(sel, el); el = sel; }
        if (el) el.innerHTML = '<option value="">Select...</option>' + whs.map(w => '<option value="' + (w.warehouseId || w.id) + '">' + w.location + '</option>').join('');
    });
    const tps = await (await fetch(API + '/transport')).json();
    ['s-tp', 'i-tp'].forEach(id => {
        let el = document.getElementById(id);
        if (el && el.tagName === 'INPUT') { const sel = document.createElement('select'); sel.id = id; sel.className = el.className; el.parentNode.replaceChild(sel, el); el = sel; }
        if (el) el.innerHTML = '<option value="">Select...</option>' + tps.map(t => '<option value="' + t.tpName + '">' + t.tpName + '</option>').join('');
    });
}

window.addShipment = async function() {
    const wh = document.getElementById('s-wh'), desc = document.getElementById('s-desc'), qty = document.getElementById('s-qty'), dest = document.getElementById('s-dest'), tp = document.getElementById('s-tp');
    await fetch(API + '/shipments', { method: 'POST', headers: {'Content-Type':'application/json'}, body: JSON.stringify({ shipmentId: 0, sourceWarehouse: wh && wh.value ? parseInt(wh.value) : null, description: desc ? desc.value : '', quantity: qty ? parseInt(qty.value) : 0, destination: dest ? dest.value : '', transportProvider: tp ? tp.value : '', status: 'Pending', createdAt: null }) });
    hideModal('ship-add'); loadShipments(); loadInventory(); go('dashboard');
};

window.addInventory = async function() {
    const wh = document.getElementById('i-wh'), desc = document.getElementById('i-desc'), qty = document.getElementById('i-qty'), tp = document.getElementById('i-tp');
    await fetch(API + '/inventory', { method: 'POST', headers: {'Content-Type':'application/json'}, body: JSON.stringify({ inventoryId: 0, warehouseId: wh && wh.value ? parseInt(wh.value) : null, description: desc ? desc.value : '', quantity: qty ? parseInt(qty.value) : 0, transportProvider: tp ? tp.value : null }) });
    hideModal('inv-add'); loadInventory();
};

async function _mapCb() {
    const mapDiv = document.getElementById('map');
    if (!mapDiv) return;
    
    // Clear the map div to remove all existing markers and reset state
    mapDiv.innerHTML = '';
    
    // Reinitialize the map
    window.mapInstance = new google.maps.Map(mapDiv, { center: { lat: -1.29, lng: 36.82 }, zoom: 4, mapId: '1c58c0dd9e35ef9c4882d48a' });

    const cityCoords = { 'Nairobi, Kenya': { lat: -1.2921, lng: 36.8219 }, 'Cape Town, South Africa': { lat: -33.9249, lng: 18.4241 }, 'Lagos, Nigeria': { lat: 6.5244, lng: 3.3792 } };
    
    try {
        const wh = await (await fetch(API + '/warehouses')).json();
        const whCoords = {};
        wh.forEach(w => {
            const wid = w.warehouseId || w.id;
            const pos = cityCoords[w.location] || { lat: -1.29, lng: 36.82 };
            whCoords[wid] = pos;
            const pin = new google.maps.marker.PinElement({ background: '#0000FF', borderColor: '#00008B', glyphColor: '#FFFFFF' });
            new google.maps.marker.AdvancedMarkerElement({ map: window.mapInstance, position: pos, content: pin.element, title: w.location });
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
            new google.maps.marker.AdvancedMarkerElement({ map: window.mapInstance, position: pos, content: wrapper, title: s.description });
        });
    } catch (err) { console.error('Map data fetch error:', err); }
}

let ws = null;
function connectWebSocket() {
    if (ws && ws.readyState === WebSocket.OPEN) return;
    ws = new WebSocket('ws://localhost:3000');
    ws.onopen = () => { const wsStatus = document.getElementById('ws-status'); if (wsStatus) { wsStatus.textContent = 'WS: Connected'; wsStatus.style.color = '#2ecc71'; } };
    ws.onmessage = (event) => {
        try {
            const shipment = JSON.parse(event.data);
            const shipList = document.getElementById('ship-list');
            if (shipList) {
                const newItem = document.createElement('div');
                newItem.className = 'list-item';
                newItem.innerHTML = shipment.description + ' -> ' + shipment.destination + ' (' + shipment.status + ') <button class="btn btn-danger" style="float:right; padding: 2px 8px; font-size: 0.8rem;" onclick="deleteShipment(' + shipment.shipmentId + ')">Remove</button>';
                shipList.prepend(newItem);
            }
            if (typeof loadInventory === 'function') loadInventory();
            if (typeof _mapCb === 'function' && document.getElementById('dashboard').classList.contains('active')) _mapCb();
        } catch (e) { console.error('WS parse error:', e); }
    };
    ws.onclose = () => { const wsStatus = document.getElementById('ws-status'); if (wsStatus) { wsStatus.textContent = 'WS: Disconnected'; wsStatus.style.color = '#e74c3c'; } setTimeout(connectWebSocket, 3000); };
}

if (localStorage.getItem('token')) { document.getElementById('login-bg').classList.remove('show'); connectWebSocket(); }
</script>
</body>
</html>"""

with open('frontend/index.html', 'w') as f:
    f.write(html_content)
print("✅ Pristine file completely overwritten via Python.")
