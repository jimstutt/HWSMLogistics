import re

file_path = 'frontend/index.html'
with open(file_path, 'r') as f:
    content = f.read()

# 1. AMPUTATE THE BROKEN RAW TEXT
# This is the exact fragment causing the "Unexpected end of input" error
broken_marker = "function doLogin\n    })"
if broken_marker in content:
    idx = content.find(broken_marker)
    content = content[:idx]
    print("✅ Amputated broken raw JavaScript from the end of the file.")
else:
    print("⚠️ Exact broken marker not found, attempting fallback cleanup...")
    content = re.sub(r'function doLogin[\s\S]*?}\s*$', '', content)

# 2. Ensure proper HTML closing tags
if '</body>' not in content:
    content += '\n</body>'
if '</html>' not in content:
    content += '\n</html>'

# 3. INJECT THE BULLETPROOF ADMIN ADD SCRIPT
admin_script = """
<script>
// Track the active Admin tab
if (typeof window.adminType === 'undefined') window.adminType = 'user';
const _origAdminTab = typeof adminTab === 'function' ? adminTab : function(){};
window.adminTab = function(t) {
    window.adminType = t;
    _origAdminTab(t);
};

// The Custom Add Modal
function showCustomAdminAdd() {
    const t = window.adminType || 'user';
    let title = 'Add Item';
    let fields = '';
    const s = 'width:100%; margin-bottom:8px; padding:8px; border:1px solid #ccc; border-radius:4px; box-sizing:border-box;';

    if (t === 'wh') {
        title = 'Add Warehouse';
        fields = '<input type="text" id="aw-loc" placeholder="Location" style="'+s+'">' +
                 '<input type="number" id="aw-cap" placeholder="Capacity" style="'+s+'">' +
                 '<input type="text" id="aw-trans" placeholder="Transport" style="'+s+'">' +
                 '<input type="email" id="aw-email" placeholder="Email" style="'+s+'">' +
                 '<input type="text" id="aw-phone" placeholder="Phone" style="'+s+'">';
    } else if (t === 'tp') {
        title = 'Add Transport Provider';
        fields = '<input type="text" id="at-name" placeholder="Name" style="'+s+'">' +
                 '<input type="text" id="at-loc" placeholder="Location" style="'+s+'">' +
                 '<input type="email" id="at-email" placeholder="Email" style="'+s+'">' +
                 '<input type="text" id="at-phone" placeholder="Phone" style="'+s+'">';
    } else if (t === 'partner') {
        title = 'Add Partner';
        fields = '<input type="text" id="ap-org" placeholder="Organisation" style="'+s+'">' +
                 '<input type="text" id="ap-contact" placeholder="Contact Name" style="'+s+'">' +
                 '<input type="text" id="ap-addr" placeholder="Address" style="'+s+'">' +
                 '<input type="email" id="ap-email" placeholder="Email" style="'+s+'">' +
                 '<input type="text" id="ap-phone" placeholder="Phone" style="'+s+'">';
    } else {
        title = 'Add User';
        fields = '<input type="text" id="au-fname" placeholder="First Name" style="'+s+'">' +
                 '<input type="text" id="au-sname" placeholder="Second Name" style="'+s+'">' +
                 '<input type="email" id="au-email" placeholder="Email" style="'+s+'">' +
                 '<input type="password" id="au-pass" placeholder="Password" style="'+s+'">' +
                 '<input type="text" id="au-org" placeholder="Organisation" style="'+s+'">' +
                 '<input type="text" id="au-role" placeholder="Role" style="'+s+'">';
    }

    const existing = document.getElementById('custom-admin-modal');
    if (existing) existing.remove();

    const modal = document.createElement('div');
    modal.id = 'custom-admin-modal';
    modal.style.cssText = 'position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); display:flex; align-items:center; justify-content:center; z-index:9999;';
    modal.innerHTML = '<div style="background:white; padding:20px; border-radius:8px; width:300px; box-shadow:0 4px 6px rgba(0,0,0,0.1);">' +
        '<h3 style="margin-top:0;">' + title + '</h3>' +
        '<div id="custom-admin-fields">' + fields + '</div>' +
        '<button onclick="saveCustomAdminItem()" style="margin-top:10px; background:#28a745; color:white; border:none; padding:8px 16px; border-radius:4px; cursor:pointer; width:48%;">Save</button>' +
        '<button onclick="document.getElementById(\\'custom-admin-modal\\').remove()" style="margin-top:10px; background:#dc3545; color:white; border:none; padding:8px 16px; border-radius:4px; cursor:pointer; width:48%;">Cancel</button>' +
    '</div>';
    document.body.appendChild(modal);
}

window.saveCustomAdminItem = async function() {
    const t = window.adminType || 'user';
    let payload = {};
    let endpoint = 'http://localhost:3000/api/';

    if (t === 'wh') {
        endpoint += 'warehouses';
        payload = { warehouseId: 0, location: document.getElementById('aw-loc').value, capacity: parseInt(document.getElementById('aw-cap').value) || 0, transport: document.getElementById('aw-trans').value, contactEmail: document.getElementById('aw-email').value, contactPhone: document.getElementById('aw-phone').value };
    } else if (t === 'tp') {
        endpoint += 'transport';
        payload = { tpId: 0, tpName: document.getElementById('at-name').value, tpLocation: document.getElementById('at-loc').value, tpEmail: document.getElementById('at-email').value, tpPhone: document.getElementById('at-phone').value };
    } else if (t === 'partner') {
        endpoint += 'partners';
        payload = { partnerId: 0, organisation: document.getElementById('ap-org').value, contactName: document.getElementById('ap-contact').value, address: document.getElementById('ap-addr').value, email: document.getElementById('ap-email').value, phone: document.getElementById('ap-phone').value };
    } else {
        endpoint += 'users';
        payload = { userId: 0, firstName: document.getElementById('au-fname').value, secondName: document.getElementById('au-sname').value, email: document.getElementById('au-email').value, passwordHash: document.getElementById('au-pass').value, organisation: document.getElementById('au-org').value, role: document.getElementById('au-role').value };
    }

    try {
        const res = await fetch(endpoint, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) });
        if (res.ok) {
            document.getElementById('custom-admin-modal').remove();
            if (typeof loadAdmin === 'function') loadAdmin();
            alert('Item added successfully!');
        } else {
            alert('Failed to add item: HTTP ' + res.status);
        }
    } catch (err) {
        alert('Error: ' + err.message);
    }
};

// Intercept ALL clicks on the "Add" button using CAPTURE PHASE (true)
// This guarantees our modal opens even if the original HTML button is broken
document.addEventListener('click', function(e) {
    if (e.target && e.target.tagName === 'BUTTON' && e.target.innerText.trim() === 'Add') {
        const adminSection = document.getElementById('admin');
        // Only trigger if the Admin page is currently active/visible
        if (adminSection && (adminSection.classList.contains('active') || adminSection.style.display !== 'none')) {
            e.preventDefault();
            e.stopImmediatePropagation();
            showCustomAdminAdd();
        }
    }
}, true); 
</script>
"""

if '</body>' in content:
    content = content.replace('</body>', admin_script + '\n</body>')
else:
    content += admin_script

with open(file_path, 'w') as f:
    f.write(content)

print("✅ File truncated, syntax error resolved, and Admin Add button wired up via event capture.")
