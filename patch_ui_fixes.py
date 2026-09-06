import re

with open('frontend/index.html', 'r') as f:
    content = f.read()

# 1. Fix Login Modal to show by default on page load
content = content.replace('<div id="login-bg" class="modal">', '<div id="login-bg" class="modal show">')

# 2. Fix Add User error alert to show the exact server response (crucial for debugging)
content = content.replace("alert('Failed: HTTP ' + res.status);", "alert('Failed: ' + await res.text());")

# 3. Add Remove buttons back to the Admin list
old_admin_map = """listEl.innerHTML = data.map(item => {
            if (adminType === 'user') return '<div class="list-item">' + item.firstName + ' ' + item.secondName + ' (' + item.email + ')</div>';
            if (adminType === 'partner') return '<div class="list-item">' + item.organisation + ' - ' + item.contactName + '</div>';
            if (adminType === 'wh') return '<div class="list-item">' + item.location + ' (Cap: ' + item.capacity + ')</div>';
            if (adminType === 'tp') return '<div class="list-item">' + item.tpName + ' (' + item.tpLocation + ')</div>';
            return '<div class="list-item">Item</div>';
        }).join('');"""

new_admin_map = """listEl.innerHTML = data.map(item => {
            let id = item.userId || item.partnerId || item.warehouseId || item.tpId || item.id;
            let type = adminType === 'wh' ? 'warehouses' : adminType === 'tp' ? 'transport' : adminType + 's';
            let text = '';
            if (adminType === 'user') text = item.firstName + ' ' + item.secondName + ' (' + item.email + ')';
            else if (adminType === 'partner') text = item.organisation + ' - ' + item.contactName;
            else if (adminType === 'wh') text = item.location + ' (Cap: ' + item.capacity + ')';
            else if (adminType === 'tp') text = item.tpName + ' (' + item.tpLocation + ')';
            else text = 'Item';
            return '<div class="list-item">' + text + ' <button class="btn btn-danger" style="float:right; padding: 2px 8px; font-size: 0.8rem;" onclick="deleteItem(\\'' + type + '\\',' + id + ')">Remove</button></div>';
        }).join('');"""
content = content.replace(old_admin_map, new_admin_map)

# 4. Add Remove buttons back to the Shipments list
old_ship_map = """document.getElementById('ship-list').innerHTML = d.map(s => '<div class="list-item">' + s.description + ' -> ' + s.destination + ' (' + s.status + ')</div>').join('');"""
new_ship_map = """document.getElementById('ship-list').innerHTML = d.map(s => '<div class="list-item">' + s.description + ' -> ' + s.destination + ' (' + s.status + ') <button class="btn btn-danger" style="float:right; padding: 2px 8px; font-size: 0.8rem;" onclick="deleteShipment(' + s.shipmentId + ')">Remove</button></div>').join('');"""
content = content.replace(old_ship_map, new_ship_map)

# 5. Add Remove buttons back to the Inventory list
old_inv_map = """html += w.items.length === 0 ? '<div class="list-item" style="color:#888;">No inventory</div>' : w.items.map(i => '<div class="list-item">' + i.description + ' x' + i.quantity + '</div>').join('');"""
new_inv_map = """html += w.items.length === 0 ? '<div class="list-item" style="color:#888;">No inventory</div>' : w.items.map(i => '<div class="list-item">' + i.description + ' x' + i.quantity + ' <button class="btn btn-danger" style="float:right; padding: 2px 8px; font-size: 0.8rem;" onclick="deleteInventory(' + i.inventoryId + ')">Remove</button></div>').join('');"""
content = content.replace(old_inv_map, new_inv_map)

# 6. Inject the missing Delete functions before the MAP section
delete_funcs = """
// --- DELETE FUNCTIONS ---
window.deleteItem = async function(type, id) {
    if(!confirm('Are you sure you want to delete this item?')) return;
    const res = await fetch(API + '/' + type + '/' + id, { method: 'DELETE' });
    if(res.ok) loadAdmin(); else alert('Delete failed: ' + await res.text());
};
window.deleteShipment = async function(id) {
    if(!confirm('Are you sure you want to delete this shipment?')) return;
    const res = await fetch(API + '/shipments/' + id, { method: 'DELETE' });
    if(res.ok) loadShipments(); else alert('Delete failed: ' + await res.text());
};
window.deleteInventory = async function(id) {
    if(!confirm('Are you sure you want to delete this inventory item?')) return;
    const res = await fetch(API + '/inventory/' + id, { method: 'DELETE' });
    if(res.ok) loadInventory(); else alert('Delete failed: ' + await res.text());
};
"""
content = content.replace("// --- MAP ---", delete_funcs + "\n// --- MAP ---")

with open('frontend/index.html', 'w') as f:
    f.write(content)

print("✅ UI patched: Login modal restored, Remove buttons added, and error reporting improved.")
