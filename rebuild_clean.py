html_content = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HWSM Logistics</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; display: flex; height: 100vh; background: #f4f4f9; }
        #sidebar { width: 220px; background: #2c3e50; color: white; display: flex; flex-direction: column; }
        #sidebar h2 { text-align: center; padding: 20px 0; margin: 0; border-bottom: 1px solid #34495e; }
        #sidebar a { color: white; text-decoration: none; padding: 15px 20px; cursor: pointer; }
        #sidebar a:hover, #sidebar a.active { background: #34495e; }
        #main { flex: 1; padding: 20px; overflow-y: auto; }
        .page { display: none; }
        .page.active { display: block; }
        #map { height: 80vh; width: 100%; background: #ddd; border-radius: 8px; }
        .btn { padding: 8px 12px; background: #3498db; color: white; border: none; border-radius: 4px; cursor: pointer; margin: 2px; }
        .btn-success { background: #2ecc71; }
        .btn-danger { background: #e74c3c; }
        .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center; }
        .modal.show { display: flex; }
        .modal-content { background: white; padding: 20px; border-radius: 8px; width: 300px; }
        .modal-content input, .modal-content select { width: 100%; margin: 5px 0; padding: 8px; box-sizing: border-box; }
        .list-item { background: white; padding: 10px; margin-bottom: 5px; border-radius: 4px; border-left: 4px solid #3498db; }
    </style>
</head>
<body>
    <div id="sidebar">
        <h2>HWSM Logistics</h2>
        <a onclick="go('dashboard')" class="active">Dashboard</a>
        <a onclick="go('shipments')">Shipments & Inventory</a>
        <a onclick="go('reports')">Reports</a>
        <a onclick="go('admin')">Admin</a>
        <div style="margin-top: auto; padding: 15px; text-align: center; cursor: pointer; background: #27ae60;" onclick="document.getElementById('login').classList.add('show')">Login</div>
        <div id="ws-status" style="padding: 10px; text-align: center; color: #e74c3c; font-size: 0.8rem;">WS: Disconnected</div>
    </div>
    <div id="main">
        <div id="dashboard" class="page active">
            <h2>Dashboard</h2>
            <div id="map"></div>
        </div>
        <div id="shipments" class="page">
            <h2>Shipments & Inventory</h2>
            <h3>Shipments</h3>
            <button class="btn btn-success" onclick="showModal('ship-add')">Add Shipment</button>
            <button class="btn" onclick="loadShipments()">Refresh</button>
            <div id="ship-list" style="margin-top:10px;"></div>
            <hr>
            <h3>Inventory</h3>
            <button class="btn btn-success" onclick="showModal('inv-add')">Add Inventory</button>
            <button class="btn" onclick="loadInventory()">Refresh</button>
            <div id="inv-list" style="margin-top:10px;"></div>
        </div>
        <div id="reports" class="page">
            <h2>Reports</h2>
            <p>Full charts coming soon.</p>
        </div>
        <div id="admin" class="page">
            <h2>Admin</h2>
            <button class="btn" onclick="adminTab('user')">Users</button>
            <button class="btn" onclick="adminTab('partner')">Partners</button>
            <button class="btn" onclick="adminTab('wh')">Warehouses</button>
            <button class="btn" onclick="adminTab('tp')">Transport</button>
            <button class="btn btn-success" onclick="showAdminAdd()">Add</button>
            <button class="btn" onclick="loadAdmin()">Refresh</button>
            <div id="admin-list" style="margin-top:10px;"></div>
        </div>
    </div>

    <div id="login" class="modal show">
        <div class="modal-content">
            <h3>Login</h3>
            <input id="lemail" value="admin@hwsm.com" placeholder="Email">
            <input id="lpass" type="password" value="admin" placeholder="Password">
            <button class="btn btn-success" onclick="doLogin()" style="width:100%; margin-top:10px;">Login</button>
        </div>
    </div>

    <div id="mod-ship-add" class="modal">
        <div class="modal-content">
            <h3>Add Shipment</h3>
            <select id="s-wh"><option>Warehouse...</option></select>
            <input id="s-desc" placeholder="Description">
            <input id="s-qty" type="number" placeholder="Quantity">
            <input id="s-dest" placeholder="Destination (e.g. Kampala)">
            <select id="s-tp"><option>Transport...</option></select>
            <button class="btn btn-success" onclick="addShipment()">Save</button>
            <button class="btn btn-danger" onclick="hideModal('ship-add')">Cancel</button>
        </div>
    </div>

    <div id="mod-inv-add" class="modal">
        <div class="modal-content">
            <h3>Add Inventory</h3>
            <select id="i-wh"><option>Warehouse...</option></select>
            <select id="i-desc">
                <option>Food</option><option>Water</option><option>Medical</option>
                <option>Sanitary</option><option>Clothing</option><option>Bedding</option><option>Shelter</option>
            </select>
            <input id="i-qty" type="number" placeholder="Quantity">
            <select id="i-tp"><option>Transport...</option></select>
            <button class="btn btn-success" onclick="addInventory()">Save</button>
            <button class="btn btn-danger" onclick="hideModal('inv-add')">Cancel</button>
        </div>
    </div>

    <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyDW_1yxgCrgZTESXigHmVFLSp398EGgb6I&callback=initMap&libraries=marker&loading=async" async defer></script>
    <script>
        const API = 'http://localhost:3000/api';
        let map;
        let adminType = 'user';

        function doLogin() {
            fetch(API + '/auth/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ loginEmail: document.getElementById('lemail').value, loginPassword: document.getElementById('lpass').value })
            }).then(r => r.json()).then(d => {
                if (d.token) {
                    localStorage.setItem('token', d.token);
                    document.getElementById('login').classList.remove('show');
                    connectWS();
                    go('dashboard');
                } else {
                    alert('Invalid credentials');
                }
            }).catch(err => alert('Login error: ' + err));
        }

        function go(p) {
            document.querySelectorAll('.page').forEach(e => e.classList.remove('active'));
            document.getElementById(p).classList.add('active');
            if (p === 'dashboard') initMap();
            if (p === 'shipments') { loadShipments(); loadInventory(); }
            if (p === 'admin') loadAdmin();
        }

        function showModal(id) {
            document.getElementById('mod-' + id).classList.add('show');
            if (id === 'ship-add' || id === 'inv-add') populateDropdowns();
        }
        function hideModal(id) {
            document.getElementById('mod-' + id).classList.remove('show');
        }

        async function initMap() {
            const d = document.getElementById('map');
            if (!d || !google.maps) return;
            map = new google.maps.Map(d, { center: { lat: -1.29, lng: 36.82 }, zoom: 4, mapId: '1c58c0dd9e35ef9c4882d48a' });
            
            // HARDCODED COORDINATES (Includes Mogadishu)
            const cityCoords = {
                'Nairobi, Kenya': { lat: -1.2921, lng: 36.8219 }, 'Nairobi': { lat: -1.2921, lng: 36.8219 },
                'Cape Town, South Africa': { lat: -33.9249, lng: 18.4241 }, 'Cape Town': { lat: -33.9249, lng: 18.4241 },
                'Lagos, Nigeria': { lat: 6.5244, lng: 3.3792 }, 'Lagos': { lat: 6.5244, lng: 3.3792 },
                'Mogadishu, Somalia': { lat: 2.0469, lng: 45.3182 }, 'Mogadishu': { lat: 2.0469, lng: 45.3182 }
            };

            try {
                const wh = await (await fetch(API + '/warehouses')).json();
                const whCoords = {};
                for (const w of wh) {
                    const pos = cityCoords[w.location] || { lat: -1.29, lng: 36.82 };
                    whCoords[w.warehouseId || w.id] = pos;
                    const pin = new google.maps.marker.PinElement({ background: '#0000FF', borderColor: '#00008B', glyphColor: '#FFFFFF' });
                    new google.maps.marker.AdvancedMarkerElement({ map, position: pos, content: pin.element, title: w.location });
                }

                const sh = await (await fetch(API + '/shipments')).json();
                for (const s of sh) {
                    const basePos = whCoords[s.sourceWarehouse] || { lat: -1.29, lng: 36.82 };
                    const pos = { lat: basePos.lat + (Math.random() - 0.5) * 2, lng: basePos.lng + (Math.random() - 0.5) * 2 };
                    const pin = new google.maps.marker.PinElement({ background: '#FF0000', borderColor: '#8B0000', glyphColor: '#FFFFFF' });
                    const labelDiv = document.createElement('div');
                    labelDiv.style.cssText = 'font-size: 11px; font-weight: bold; background: rgba(255,255,255,0.95); color: #333; padding: 2px 6px; border-radius: 4px; margin-top: 4px; white-space: nowrap; border: 1px solid #ccc;';
                    labelDiv.textContent = s.description + ' -> ' + s.destination;
                    const wrapper = document.createElement('div');
                    wrapper.style.cssText = 'display: flex; flex-direction: column; align-items: center;';
                    wrapper.appendChild(pin.element);
                    wrapper.appendChild(labelDiv);
                    new google.maps.marker.AdvancedMarkerElement({ map, position: pos, content: wrapper, title: s.description });
                }
            } catch (e) { console.error('Map error:', e); }
        }

        async function loadShipments() {
            const d = await (await fetch(API + '/shipments')).json();
            document.getElementById('ship-list').innerHTML = d.map(s => '<div class="list-item">' + s.description + ' -> ' + s.destination + ' <button class="btn btn-danger" style="float:right;padding:2px 8px;" onclick="deleteShipment(' + s.shipmentId + ')">Remove</button></div>').join('');
        }

        async function loadInventory() {
            const inv = await (await fetch(API + '/inventory')).json();
            const wh = await (await fetch(API + '/warehouses')).json();
            const whMap = {};
            wh.forEach(w => whMap[w.warehouseId || w.id] = w.location);
            let html = '';
            inv.forEach(i => {
                html += '<div class="list-item">' + (whMap[i.warehouseId] || 'Unknown') + ': ' + i.description + ' x' + i.quantity + ' <button class="btn btn-danger" style="float:right;padding:2px 8px;" onclick="deleteInventory(' + i.inventoryId + ')">Remove</button></div>';
            });
            document.getElementById('inv-list').innerHTML = html;
        }

        async function loadAdmin() {
            let endpoint = API + '/' + (adminType === 'wh' ? 'warehouses' : adminType === 'tp' ? 'transport' : adminType + 's');
            const data = await (await fetch(endpoint)).json();
            document.getElementById('admin-list').innerHTML = data.map(item => {
                let id = item.userId || item.partnerId || item.warehouseId || item.tpId || item.id;
                let type = adminType === 'wh' ? 'warehouses' : adminType === 'tp' ? 'transport' : adminType + 's';
                let text = item.firstName || item.organisation || item.location || item.tpName || 'Item';
                return '<div class="list-item">' + text + ' <button class="btn btn-danger" style="float:right;padding:2px 8px;" onclick="deleteItem(\\'' + type + '\\',' + id + ')">Remove</button></div>';
            }).join('');
        }

        function adminTab(t) { adminType = t; loadAdmin(); }
        function showAdminAdd() { alert('Admin Add modal logic here'); }

        async function populateDropdowns() {
            const whs = await (await fetch(API + '/warehouses')).json();
            const tps = await (await fetch(API + '/transport')).json();
            ['s-wh', 'i-wh'].forEach(id => {
                const el = document.getElementById(id);
                el.innerHTML = '<option value="">Select Warehouse...</option>' + whs.map(w => '<option value="' + (w.warehouseId || w.id) + '">' + w.location + '</option>').join('');
            });
            ['s-tp', 'i-tp'].forEach(id => {
                const el = document.getElementById(id);
                el.innerHTML = '<option value="">Select Transport...</option>' + tps.map(t => '<option value="' + t.tpName + '">' + t.tpName + '</option>').join('');
            });
        }

        window.addShipment = async function() {
            await fetch(API + '/shipments', {
                method: 'POST', headers: {'Content-Type':'application/json'},
                body: JSON.stringify({
                    shipmentId: 0,
                    sourceWarehouse: parseInt(document.getElementById('s-wh').value) || null,
                    description: document.getElementById('s-desc').value,
                    quantity: parseInt(document.getElementById('s-qty').value) || 0,
                    destination: document.getElementById('s-dest').value,
                    transportProvider: document.getElementById('s-tp').value,
                    status: 'Pending', createdAt: null
                })
            });
            hideModal('ship-add'); loadShipments(); loadInventory(); go('dashboard');
        };

        window.addInventory = async function() {
            await fetch(API + '/inventory', {
                method: 'POST', headers: {'Content-Type':'application/json'},
                body: JSON.stringify({
                    inventoryId: 0,
                    warehouseId: parseInt(document.getElementById('i-wh').value) || null,
                    description: document.getElementById('i-desc').value,
                    quantity: parseInt(document.getElementById('i-qty').value) || 0,
                    transportProvider: document.getElementById('i-tp').value
                })
            });
            hideModal('inv-add'); loadInventory();
        };

        window.deleteItem = async function(type, id) {
            if(!confirm('Are you sure?')) return;
            await fetch(API + '/' + type + '/' + id, { method: 'DELETE' });
            loadAdmin();
        };
        window.deleteShipment = async function(id) {
            if(!confirm('Are you sure?')) return;
            await fetch(API + '/shipments/' + id, { method: 'DELETE' });
            loadShipments();
        };
        window.deleteInventory = async function(id) {
            if(!confirm('Are you sure?')) return;
            await fetch(API + '/inventory/' + id, { method: 'DELETE' });
            loadInventory();
        };

        let ws;
        function connectWS() {
            ws = new WebSocket('ws://localhost:3000');
            ws.onopen = () => {
                document.getElementById('ws-status').textContent = 'WS: Connected';
                document.getElementById('ws-status').style.color = '#2ecc71';
            };
            ws.onmessage = (event) => {
                try {
                    const shipment = JSON.parse(event.data);
                    loadShipments(); loadInventory();
                    if (document.getElementById('dashboard').classList.contains('active')) initMap();
                } catch (e) {}
            };
            ws.onclose = () => {
                document.getElementById('ws-status').textContent = 'WS: Disconnected';
                document.getElementById('ws-status').style.color = '#e74c3c';
                setTimeout(connectWS, 3000);
            };
        }

        if (localStorage.getItem('token')) {
            document.getElementById('login').classList.remove('show');
            connectWS();
        }
    </script>
</body>
</html>"""

with open('frontend/index.html', 'w') as f:
    f.write(html_content)
print("✅ File completely overwritten with clean HTML and hardcoded Mogadishu coordinates.")
