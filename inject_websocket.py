import re

with open('frontend/index.html', 'r') as f:
    content = f.read()

# 1. Add WS status indicator to the sidebar if not present
if 'ws-status' not in content:
    content = content.replace(
        '<div class="login-btn"',
        '<div id="ws-status" style="text-align: center; padding: 10px; font-size: 0.8rem; color: #e74c3c;">WS: Disconnected</div>\n    <div class="login-btn"'
    )

# 2. Remove any broken/mangled WS text from previous attempts
content = re.sub(r'WS: Disconnected\s*$', '', content)
content = re.sub(r'function doLogin[\s\S]*?}\s*$', '', content) # Clean up any trailing broken JS

# 3. The robust WebSocket script
ws_script = """

// --- WEBSOCKET REAL-TIME UPDATES ---
let ws = null;
function connectWebSocket() {
    if (ws && ws.readyState === WebSocket.OPEN) return;
    
    ws = new WebSocket('ws://localhost:3000');
    
    ws.onopen = () => {
        console.log('✅ WebSocket connected');
        const wsStatus = document.getElementById('ws-status');
        if (wsStatus) { wsStatus.textContent = 'WS: Connected'; wsStatus.style.color = '#2ecc71'; }
    };
    
    ws.onmessage = (event) => {
        try {
            const shipment = JSON.parse(event.data);
            console.log('📩 Real-time shipment update:', shipment);
            
            // 1. Update Shipments List instantly
            const shipList = document.getElementById('ship-list');
            if (shipList) {
                const newItem = document.createElement('div');
                newItem.className = 'list-item';
                newItem.innerHTML = shipment.description + ' -> ' + shipment.destination + ' (' + shipment.status + ') <button class="btn btn-danger" style="float:right; padding: 2px 8px; font-size: 0.8rem;" onclick="deleteShipment(' + shipment.shipmentId + ')">Remove</button>';
                shipList.prepend(newItem);
            }
            
            // 2. Update Inventory (Reload to ensure accuracy since backend decremented it)
            if (typeof loadInventory === 'function') loadInventory();
            
            // 3. Update Map (Add new red marker with text tag)
            if (window.mapInstance && typeof google !== 'undefined' && shipment.sourceWarehouse) {
                fetch(API + '/warehouses').then(r => r.json()).then(whs => {
                    const wh = whs.find(w => (w.warehouseId || w.id) === shipment.sourceWarehouse);
                    if (wh) {
                        const cityCoords = { 'Nairobi, Kenya': { lat: -1.2921, lng: 36.8219 }, 'Cape Town, South Africa': { lat: -33.9249, lng: 18.4241 }, 'Lagos, Nigeria': { lat: 6.5244, lng: 3.3792 } };
                        const pos = cityCoords[wh.location] || { lat: -1.29, lng: 36.82 };
                        const finalPos = { lat: pos.lat + (Math.random() - 0.5) * 2, lng: pos.lng + (Math.random() - 0.5) * 2 };
                        
                        const pin = new google.maps.marker.PinElement({ background: '#FF0000', borderColor: '#8B0000', glyphColor: '#FFFFFF' });
                        const labelDiv = document.createElement('div');
                        labelDiv.style.cssText = 'font-size: 11px; font-weight: bold; background: rgba(255,255,255,0.95); color: #333; padding: 2px 6px; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.3); margin-top: 4px; white-space: nowrap; border: 1px solid #ccc;';
                        labelDiv.textContent = shipment.description + ' -> ' + shipment.destination;
                        const wrapper = document.createElement('div');
                        wrapper.style.cssText = 'display: flex; flex-direction: column; align-items: center;';
                        wrapper.appendChild(pin.element);
                        wrapper.appendChild(labelDiv);
                        new google.maps.marker.AdvancedMarkerElement({ map: mapInstance, position: finalPos, content: wrapper, title: shipment.description });
                    }
                }).catch(() => {});
            }
        } catch (e) {
            console.error('WS parse error:', e);
        }
    };
    
    ws.onclose = () => {
        console.log('❌ WebSocket disconnected. Reconnecting in 3s...');
        const wsStatus = document.getElementById('ws-status');
        if (wsStatus) { wsStatus.textContent = 'WS: Disconnected'; wsStatus.style.color = '#e74c3c'; }
        setTimeout(connectWebSocket, 3000);
    };
    
    ws.onerror = (err) => {
        console.error('WebSocket error:', err);
    };
}

// Auto-connect if already logged in
if (localStorage.getItem('token')) {
    connectWebSocket();
}
"""

# Insert before the final </script>
if 'connectWebSocket' not in content:
    content = content.replace('</script>\n</body>', ws_script + '\n</script>\n</body>')
    
    # Trigger connection immediately upon successful login
    content = content.replace(
        "localStorage.setItem('token', data.token);",
        "localStorage.setItem('token', data.token);\n            connectWebSocket();"
    )

with open('frontend/index.html', 'w') as f:
    f.write(content)

print("✅ Real-time WebSocket updates and status indicator injected.")
