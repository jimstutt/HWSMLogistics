{-# LANGUAGE OverloadedStrings #-}
module Main where
import qualified Data.Text.IO as T
main :: IO ()
main = do
  T.putStrLn "<!DOCTYPE html><html><head><meta charset='utf-8'><title>HWSM Logistics</title>"
  T.putStrLn "<style>"
  T.putStrLn "*{box-sizing:border-box;margin:0;padding:0}"
  T.putStrLn "body{font-family:sans-serif;background:#f5f5f5}"
  T.putStrLn "nav{width:110px;background:#f4f4f0;height:100vh;position:fixed;left:0;top:0;padding:15px;border-right:1px solid #ddd}"
  T.putStrLn "nav h3{font-size:14px;margin-bottom:15px;color:#333}"
  T.putStrLn "nav a{display:block;color:#000;text-decoration:none;padding:8px 0;font-size:13px;font-weight:bold}"
  T.putStrLn "nav a:hover{color:#007bff}"
  T.putStrLn "main{margin-left:110px;padding:20px}"
  T.putStrLn ".page{display:none}.page.active{display:block}"
  T.putStrLn ".modal-bg{display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.5);z-index:1000;justify-content:center;align-items:center}"
  T.putStrLn ".modal-bg.show{display:flex}"
  T.putStrLn ".modal{background:#fff;padding:25px;border-radius:8px;width:350px;max-height:80vh;overflow-y:auto}"
  T.putStrLn ".modal h2{margin-bottom:15px;text-align:center}"
  T.putStrLn ".modal input,.modal select{width:100%;padding:8px;margin:6px 0;border:1px solid #ccc;border-radius:4px}"
  T.putStrLn ".modal button{width:100%;padding:10px;margin-top:10px;background:#007bff;color:#fff;border:none;border-radius:4px;cursor:pointer}"
  T.putStrLn ".modal button:hover{background:#0056b3}"
  T.putStrLn ".btn{padding:6px 14px;margin:2px;border:none;border-radius:4px;cursor:pointer;font-size:13px}"
  T.putStrLn ".btn-add{background:#28a745;color:#fff}.btn-edit{background:#ffc107;color:#000}.btn-del{background:#dc3545;color:#fff}.btn-refresh{background:#6c757d;color:#fff}"
  T.putStrLn ".toolbar{margin-bottom:10px;display:flex;gap:5px;align-items:center}"
  T.putStrLn ".list-box{height:300px;overflow-y:auto;border:1px solid #ddd;border-radius:4px;background:#fff}"
  T.putStrLn ".list-item{padding:8px 12px;border-bottom:1px solid #eee;cursor:pointer;font-size:13px}"
  T.putStrLn ".list-item:hover,.list-item.sel{background:#e2e6ea}"
  T.putStrLn ".row{display:flex;gap:20px}"
  T.putStrLn ".col{flex:1}"
  T.putStrLn "#map{height:calc(100vh - 80px);width:100%;border-radius:8px;background:#e9ecef;display:flex;align-items:center;justify-content:center;color:#6c757d}"
  T.putStrLn ".stats{display:flex;gap:15px;margin-bottom:15px}"
  T.putStrLn ".stat-card{flex:1;background:#fff;padding:15px;border-radius:8px;text-align:center;height:80px;display:flex;flex-direction:column;justify-content:center}"
  T.putStrLn ".stat-card h4{font-size:22px;color:#333}.stat-card p{font-size:11px;color:#666}"
  T.putStrLn ".tabs{display:flex;gap:5px;margin-bottom:10px}"
  T.putStrLn ".tab{padding:8px 16px;background:#ddd;border:none;cursor:pointer;border-radius:4px 4px 0 0}"
  T.putStrLn ".tab.active{background:#fff;font-weight:bold}"
  T.putStrLn "#ws-status{position:fixed;bottom:10px;right:10px;padding:5px 10px;border-radius:4px;font-size:12px;color:#fff;background:#dc3545}"
  T.putStrLn "#ws-status.connected{background:#28a745}"
  T.putStrLn "</style></head><body>"
  T.putStrLn "<nav><h3>Menu</h3><a href='#dashboard' onclick='go(\"dashboard\")'>Dashboard</a><a href='#shipments' onclick='go(\"shipments\")'>Shipments</a><a href='#reports' onclick='go(\"reports\")'>Reports</a><a href='#admin' onclick='go(\"admin\")'>Admin</a></nav>"
  T.putStrLn "<main>"
  T.putStrLn "<div id='login-bg' class='modal-bg show'><div class='modal'><h2>Login</h2><input id='lemail' placeholder='Email' value='admin@example.org'><input id='lpass' type='password' placeholder='Password' value='password123'><button onclick='doLogin()'>Login</button><p id='lerr' style='color:red;margin-top:8px'></p></div></div>"
  T.putStrLn "<div id='pg-dashboard' class='page'><h2>Dashboard</h2><div id='map'>Map loaded. (Shipment coordinates removed per request)</div></div>"
  T.putStrLn "<div id='pg-shipments' class='page'><h2>Shipments &amp; Inventory</h2><div class='row'><div class='col'><div class='toolbar'><button class='btn btn-add' onclick='showModal(\"ship-add\")'>Add Shipment</button><button class='btn btn-del' onclick='delShipment()'>Remove</button><button class='btn btn-refresh' onclick='loadShipments()'>Refresh</button></div><div id='ship-list' class='list-box'></div></div><div class='col'><div class='toolbar'><button class='btn btn-add' onclick='showModal(\"inv-add\")'>Add Inventory</button><button class='btn btn-del' onclick='delInventory()'>Remove</button><button class='btn btn-refresh' onclick='loadInventory()'>Refresh</button></div><div id='inv-list' class='list-box'></div></div></div></div>"
  T.putStrLn "<div id='pg-reports' class='page'><h2>Reports</h2><div class='stats'><div class='stat-card'><h4 id='st-ship'>0</h4><p>Total Shipments</p></div><div class='stat-card'><h4 id='st-inv'>0</h4><p>Inventory Items</p></div><div class='stat-card'><h4 id='st-wh'>0</h4><p>Warehouses</p></div><div class='stat-card'><h4 id='st-part'>0</h4><p>Partners</p></div></div><p>Full charts coming soon.</p></div>"
  T.putStrLn "<div id='pg-admin' class='page'><h2>Admin</h2><div class='tabs'><button class='tab active' onclick='adminTab(\"users\")'>Users</button><button class='tab' onclick='adminTab(\"partners\")'>Partners</button><button class='tab' onclick='adminTab(\"warehouses\")'>Warehouses</button><button class='tab' onclick='adminTab(\"transport\")'>Transport</button></div><div class='toolbar'><button class='btn btn-add' onclick='showModal(\"admin-add\")'>Add</button><button class='btn btn-del' onclick='delAdmin()'>Remove</button><button class='btn btn-refresh' onclick='loadAdmin()'>Refresh</button></div><div id='admin-list' class='list-box'></div></div>"
  T.putStrLn "</main>"
  T.putStrLn "<div id='mod-ship-add' class='modal-bg'><div class='modal'><h2>Add Shipment</h2><select id='s-wh'><option value=''>Warehouse...</option></select><input id='s-desc' placeholder='Description'><input id='s-qty' type='number' placeholder='Quantity'><input id='s-dest' placeholder='Destination'><input id='s-tp' placeholder='Transport Provider'><button onclick='addShipment()'>Save</button><button onclick='hideModal(\"ship-add\")' style='background:#6c757d'>Cancel</button></div></div>"
  T.putStrLn "<div id='mod-inv-add' class='modal-bg'><div class='modal'><h2>Add Inventory</h2><select id='i-wh'><option value=''>Warehouse...</option></select><select id='i-desc'><option>Food</option><option>Water</option><option>Medical</option><option>Sanitary</option><option>Clothing</option><option>Bedding</option><option>Shelter</option></select><input id='i-qty' type='number' placeholder='Quantity'><input id='i-tp' placeholder='Transport Provider'><button onclick='addInventory()'>Save</button><button onclick='hideModal(\"inv-add\")' style='background:#6c757d'>Cancel</button></div></div>"
  T.putStrLn "<div id='mod-admin-add' class='modal-bg'><div class='modal'><h2 id='adm-title'>Add</h2><div id='adm-fields'></div><button onclick='addAdmin()'>Save</button><button onclick='hideModal(\"admin-add\")' style='background:#6c757d'>Cancel</button></div></div>"
  T.putStrLn "<div id='ws-status'>WS: Disconnected</div>"
  
  T.putStrLn "<script>"
  T.putStrLn "const API='http://localhost:3000/api';"
  T.putStrLn "let selShip=null,selInv=null,selAdmin=null,adminType='users',mapInstance=null;"
  
  T.putStrLn "const wsStatus = document.getElementById('ws-status');"
  T.putStrLn "let ws = new WebSocket('ws://localhost:3000');"
  T.putStrLn "ws.onopen = () => { wsStatus.textContent = 'WS: Connected'; wsStatus.classList.add('connected'); };"
  T.putStrLn "ws.onclose = () => { wsStatus.textContent = 'WS: Disconnected'; wsStatus.classList.remove('connected'); };"
  T.putStrLn "ws.onmessage = (event) => { try { const data = JSON.parse(event.data); console.log('Real-time update:', data); if (document.getElementById('pg-shipments').classList.contains('active')) { loadShipments(); loadInventory(); } } catch (e) { console.error('WS parse error', e); } };"
  
  T.putStrLn "function go(p){document.querySelectorAll('.page').forEach(e=>e.classList.remove('active'));document.getElementById('pg-'+p).classList.add('active');if(p==='shipments'){loadShipments();loadInventory();}if(p==='reports')loadStats();if(p==='admin')loadAdmin();}"
  T.putStrLn "async function doLogin(){const r=await fetch(API+'/auth/login',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({loginEmail:document.getElementById('lemail').value,loginPassword:document.getElementById('lpass').value})});if(r.ok){document.getElementById('login-bg').classList.remove('show');go('dashboard');}else{document.getElementById('lerr').textContent='Login failed';}}"
  
  T.putStrLn "async function loadShipments(){const r=await fetch(API+'/shipments');const d=await r.json();const el=document.getElementById('ship-list');el.innerHTML=d.map(s=>'<div class=\"list-item\" onclick=\"selShip='+s.shipmentId+';this.classList.add(\\'sel\\')\">'+s.description+' - '+s.destination+' ('+s.status+')</div>').join('');fillWhSelect();}"
  T.putStrLn "async function loadInventory(){const r=await fetch(API+'/inventory');const d=await r.json();document.getElementById('inv-list').innerHTML=d.map(i=>'<div class=\"list-item\" onclick=\"selInv='+i.inventoryId+';this.classList.add(\\'sel\\')\">'+i.description+' x'+i.quantity+'</div>').join('');}"
  
  T.putStrLn "async function addShipment(){await fetch(API+'/shipments',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({shipmentId:0,sourceWarehouse:parseInt(document.getElementById('s-wh').value)||null,description:document.getElementById('s-desc').value,quantity:parseInt(document.getElementById('s-qty').value)||0,destination:document.getElementById('s-dest').value,transportProvider:document.getElementById('s-tp').value||null,status:'Pending',createdAt:null})});hideModal('ship-add');loadShipments();loadInventory();}"
  T.putStrLn "async function delShipment(){if(selShip){await fetch(API+'/shipments/'+selShip,{method:'DELETE'});selShip=null;loadShipments();loadInventory();}}"
  
  T.putStrLn "async function addInventory(){await fetch(API+'/inventory',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({inventoryId:0,warehouseId:parseInt(document.getElementById('i-wh').value)||null,description:document.getElementById('i-desc').value,quantity:parseInt(document.getElementById('i-qty').value)||0,transportProvider:document.getElementById('i-tp').value||null})});hideModal('inv-add');loadInventory();}"
  T.putStrLn "async function delInventory(){if(selInv){await fetch(API+'/inventory/'+selInv,{method:'DELETE'});selInv=null;loadInventory();}}"
  
  T.putStrLn "async function fillWhSelect(){const r=await fetch(API+'/warehouses');const d=await r.json();['s-wh','i-wh'].forEach(id=>{const el=document.getElementById(id);el.innerHTML='<option value=\"\">Warehouse...</option>'+d.map(w=>'<option value=\"'+w.warehouseId+'\">'+w.location+'</option>').join('');});}"
  
  T.putStrLn "async function loadStats(){try{const[s,i,w,p]=await Promise.all([fetch(API+'/shipments').then(r=>r.json()),fetch(API+'/inventory').then(r=>r.json()),fetch(API+'/warehouses').then(r=>r.json()),fetch(API+'/partners').then(r=>r.json())]);document.getElementById('st-ship').textContent=s.length;document.getElementById('st-inv').textContent=i.length;document.getElementById('st-wh').textContent=w.length;document.getElementById('st-part').textContent=p.length;}catch(e){console.error('Stats load error',e);}}"
  
  T.putStrLn "function adminTab(t){adminType=t;document.querySelectorAll('.tab').forEach(e=>e.classList.remove('active'));event.target.classList.add('active');loadAdmin();}"
  T.putStrLn "async function loadAdmin(){const r=await fetch(API+'/'+adminType);const d=await r.json();document.getElementById('admin-list').innerHTML=d.map(x=>'<div class=\"list-item\" onclick=\"selAdmin='+Object.values(x)[0]+';this.classList.add(\\'sel\\')\">'+Object.values(x).slice(1,4).join(' | ')+'</div>').join('');}"
  T.putStrLn "async function delAdmin(){if(selAdmin){await fetch(API+'/'+adminType+'/'+selAdmin,{method:'DELETE'});selAdmin=null;loadAdmin();}}"
  
  T.putStrLn "function showModal(n){if(n==='admin-add'){document.getElementById('adm-title').textContent='Add '+adminType.slice(0,-1);let f='';if(adminType==='users')f='<input id=\"a-fn\" placeholder=\"First Name\"><input id=\"a-sn\" placeholder=\"Second Name\"><input id=\"a-em\" placeholder=\"Email\"><input id=\"a-org\" placeholder=\"Organisation\"><input id=\"a-role\" placeholder=\"Role\">';else if(adminType==='partners')f='<input id=\"a-org\" placeholder=\"Organisation\"><input id=\"a-cn\" placeholder=\"Contact Name\"><input id=\"a-addr\" placeholder=\"Address\"><input id=\"a-em\" placeholder=\"Email\"><input id=\"a-ph\" placeholder=\"Phone\">';else if(adminType==='warehouses')f='<input id=\"a-loc\" placeholder=\"Location\"><input id=\"a-cap\" type=\"number\" placeholder=\"Capacity\"><input id=\"a-tr\" placeholder=\"Transport\"><input id=\"a-ce\" placeholder=\"Contact Email\"><input id=\"a-cp\" placeholder=\"Contact Phone\">';else if(adminType==='transport')f='<input id=\"a-nm\" placeholder=\"Name\"><input id=\"a-loc\" placeholder=\"Location\"><input id=\"a-em\" placeholder=\"Email\"><input id=\"a-ph\" placeholder=\"Phone\">';document.getElementById('adm-fields').innerHTML=f;}document.getElementById('mod-'+n).classList.add('show');}"
  T.putStrLn "function hideModal(n){document.getElementById('mod-'+n).classList.remove('show');}"
  
  T.putStrLn "async function addAdmin(){let p={};if(adminType==='users')p={firstName:document.getElementById('a-fn').value,secondName:document.getElementById('a-sn').value,email:document.getElementById('a-em').value,organisation:document.getElementById('a-org').value,role:document.getElementById('a-role').value};else if(adminType==='partners')p={partnerOrg:document.getElementById('a-org').value,contactName:document.getElementById('a-cn').value,address:document.getElementById('a-addr').value,partnerEmail:document.getElementById('a-em').value,partnerPhone:document.getElementById('a-ph').value};else if(adminType==='warehouses')p={location:document.getElementById('a-loc').value,capacity:parseInt(document.getElementById('a-cap').value)||0,transport:document.getElementById('a-tr').value,contactEmail:document.getElementById('a-ce').value,contactPhone:document.getElementById('a-cp').value};else if(adminType==='transport')p={tpName:document.getElementById('a-nm').value,tpLocation:document.getElementById('a-loc').value,tpEmail:document.getElementById('a-em').value,tpPhone:document.getElementById('a-ph').value};await fetch(API+'/'+adminType,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(p)});hideModal('admin-add');loadAdmin();}"
  
  T.putStrLn "</script></body></html>"
