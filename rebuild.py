html = """<!DOCTYPE html>
<html><head><title>HWSM Logistics</title>
<style>
body{font-family:Arial;margin:0;display:flex;height:100vh;}
#sidebar{width:200px;background:#2c3e50;color:white;padding:20px;}
#sidebar a{color:white;display:block;padding:10px;cursor:pointer;}
#sidebar a:hover{background:#34495e;}
#main{flex:1;padding:20px;overflow-y:auto;}
.page{display:none;}.page.active{display:block;}
#map{height:80vh;width:100%;background:#eee;border-radius:8px;}
.btn{padding:5px 10px;background:#3498db;color:white;border:none;cursor:pointer;margin:2px;border-radius:4px;}
.modal{display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.5);}
.modal.show{display:flex;align-items:center;justify-content:center;}
.modal-content{background:white;padding:20px;border-radius:8px;width:300px;}
.modal-content input{width:100%;margin:5px 0;padding:8px;box-sizing:border-box;}
</style></head><body>
<div id='sidebar'>
<h2>HWSM Logistics</h2>
<a onclick="go('dashboard')">Dashboard</a>
<a onclick="go('shipments')">Shipments</a>
<a onclick="go('admin')">Admin</a>
<a onclick="document.getElementById('login').classList.add('show')">Login</a>
<div id='ws' style='color:red;margin-top:20px;font-size:0.8rem;'>WS: Disconnected</div>
</div>
<div id='main'>
<div id='dashboard' class='page active'><h2>Dashboard</h2><div id='map'></div></div>
<div id='shipments' class='page'><h2>Shipments</h2><div id='ship-list'></div></div>
<div id='admin' class='page'><h2>Admin</h2><div id='admin-list'></div></div>
</div>
<div id='login' class='modal show'><div class='modal-content'>
<h3>Login</h3>
<input id='lemail' value='admin@hwsm.com' placeholder='Email'>
<input id='lpass' type='password' value='admin' placeholder='Password'>
<button class='btn' onclick='doLogin()' style='width:100%;margin-top:10px;background:#2ecc71;'>Login</button>
</div></div>
<script src='https://maps.googleapis.com/maps/api/js?key=AIzaSyDW_1yxgCrgZTESXigHmVFLSp398EGgb6I&callback=initMap&libraries=marker&loading=async' async defer></script>
<script>
const API='http://localhost:3000/api';
let map;

function doLogin(){
  fetch(API+'/auth/login',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({loginEmail:document.getElementById('lemail').value,loginPassword:document.getElementById('lpass').value})})
  .then(r=>r.json()).then(d=>{
    if(d.token){localStorage.setItem('token',d.token);document.getElementById('login').classList.remove('show');connectWS();go('dashboard');}
  });
}

function go(p){
  document.querySelectorAll('.page').forEach(e=>e.classList.remove('active'));
  document.getElementById(p).classList.add('active');
  if(p==='dashboard')initMap();
}

async function initMap(){
  const d=document.getElementById('map');
  if(!d||!google.maps)return;
  map=new google.maps.Map(d,{center:{lat:-1.29,lng:36.82},zoom:4,mapId:'1c58c0dd9e35ef9c4882d48a'});
  const g=new google.maps.Geocoder();
  
  // Plot Warehouses (Blue)
  const wh=await(await fetch(API+'/warehouses')).json();
  for(const w of wh){
    g.geocode({address:w.location},(r,s)=>{
      if(s==='OK'){
        const pin=new google.maps.marker.PinElement({background:'#0000FF',borderColor:'#00008B',glyphColor:'#FFFFFF'});
        new google.maps.marker.AdvancedMarkerElement({map,position:r[0].geometry.location,content:pin.element,title:w.location});
      }
    });
  }
  
  // Plot Shipments (Red)
  const sh=await(await fetch(API+'/shipments')).json();
  for(const s of sh){
    g.geocode({address:s.destination},(r,s)=>{
      if(s==='OK'){
        const pin=new google.maps.marker.PinElement({background:'#FF0000',borderColor:'#8B0000',glyphColor:'#FFFFFF'});
        new google.maps.marker.AdvancedMarkerElement({map,position:r[0].geometry.location,content:pin.element,title:s.description});
      }
    });
  }
}

let ws;
function connectWS(){
  ws=new WebSocket('ws://localhost:3000');
  ws.onopen=()=>{document.getElementById('ws').textContent='WS: Connected';document.getElementById('ws').style.color='green';};
  ws.onclose=()=>{document.getElementById('ws').textContent='WS: Disconnected';document.getElementById('ws').style.color='red';setTimeout(connectWS,3000);};
}

if(localStorage.getItem('token')){document.getElementById('login').classList.remove('show');connectWS();}
</script></body></html>"""

with open('frontend/index.html', 'w') as f:
    f.write(html)
print("✅ File rebuilt successfully with Geocoding.")
