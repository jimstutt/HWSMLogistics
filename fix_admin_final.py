import re

# 1. Create the pure JS file (No HTML escaping needed!)
js_code = """
function showAdminAddModal() {
    const activeTab = document.querySelector('.tab.active');
    let tabName = '';
    if (activeTab) {
        const onclickAttr = activeTab.getAttribute('onclick') || '';
        if (onclickAttr.includes('wh')) tabName = 'wh';
        else if (onclickAttr.includes('user')) tabName = 'user';
        else if (onclickAttr.includes('partner')) tabName = 'partner';
        else if (onclickAttr.includes('tp')) tabName = 'tp';
    }
    
    let fieldsHTML = '';
    let title = 'Add Item';
    const inputStyle = 'width:100%; margin-bottom:8px; padding:8px; border:1px solid #ccc; border-radius:4px; box-sizing:border-box;';

    if (tabName === 'wh') {
        title = 'Add Warehouse';
        fieldsHTML = `
            <input type="text" id="aw-loc" placeholder="Location (e.g., Nairobi, Kenya)" style="${inputStyle}">
            <input type="number" id="aw-cap" placeholder="Capacity" style="${inputStyle}">
            <input type="text" id="aw-trans" placeholder="Transport (e.g., Road)" style="${inputStyle}">
            <input type="email" id="aw-email" placeholder="Contact Email" style="${inputStyle}">
            <input type="text" id="aw-phone" placeholder="Contact Phone" style="${inputStyle}">
        `;
    } else if (tabName === 'user') {
        title = 'Add User';
        fieldsHTML = `
            <input type="text" id="au-fname" placeholder="First Name" style="${inputStyle}">
            <input type="text" id="au-sname" placeholder="Second Name" style="${inputStyle}">
            <input type="email" id="au-email" placeholder="Email" style="${inputStyle}">
            <input type="password" id="au-pass" placeholder="Password" style="${inputStyle}">
            <input type="text" id="au-org" placeholder="Organisation" style="${inputStyle}">
            <input type="text" id="au-role" placeholder="Role (e.g., admin)" style="${inputStyle}">
        `;
    } else if (tabName === 'partner') {
        title = 'Add Partner';
        fieldsHTML = `
            <input type="text" id="ap-org" placeholder="Organisation" style="${inputStyle}">
            <input type="text" id="ap-contact" placeholder="Contact Name" style="${inputStyle}">
            <input type="text" id="ap-addr" placeholder="Address" style="${inputStyle}">
            <input type="email" id="ap-email" placeholder="Email" style="${inputStyle}">
            <input type="text" id="ap-phone" placeholder="Phone" style="${inputStyle}">
        `;
    } else if (tabName === 'tp') {
        title = 'Add Transport Provider';
        fieldsHTML = `
            <input type="text" id="at-name" placeholder="Name" style="${inputStyle}">
            <input type="text" id="at-loc" placeholder="Location" style="${inputStyle}">
            <input type="email" id="at-email" placeholder="Email" style="${inputStyle}">
            <input type="text" id="at-phone" placeholder="Phone" style="${inputStyle}">
        `;
    }

    const modalHTML = `
        <div id="admin-add-modal" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); display:flex; align-items:center; justify-content:center; z-index:1000;">
            <div style="background:white; padding:20px; border-radius:8px; width:300px; max-height:80vh; overflow-y:auto; box-shadow:0 4px 6px rgba(0,0,0,0.1);">
                <h3 id="admin-add-title" style="margin-top:0;">${title}</h3>
                <div id="admin-add-fields">${fieldsHTML}</div>
                <button onclick="saveAdminItem()" style="margin-top:10px; background:#28a745; color:white; border:none; padding:8px 16px; border-radius:4px; cursor:pointer;">Save</button>
                <button onclick="document.getElementById('admin-add-modal').remove()" style="margin-top:10px; margin-left:10px; background:#dc3545; color:white; border:none; padding:8px 16px; border-radius:4px; cursor:pointer;">Cancel</button>
            </div>
        </div>
    `;
    
    document.body.insertAdjacentHTML('beforeend', modalHTML);
}

window.saveAdminItem = async function() {
    const activeTab = document.querySelector('.tab.active');
    let tabName = '';
    if (activeTab) {
        const onclickAttr = activeTab.getAttribute('onclick') || '';
        if (onclickAttr.includes('wh')) tabName = 'wh';
        else if (onclickAttr.includes('user')) tabName = 'user';
        else if (onclickAttr.includes('partner')) tabName = 'partner';
        else if (onclickAttr.includes('tp')) tabName = 'tp';
    }

    let payload = {};
    let endpoint = '';

    if (tabName === 'wh') {
        endpoint = API + '/warehouses';
        payload = { warehouseId: 0, location: document.getElementById('aw-loc').value, capacity: parseInt(document.getElementById('aw-cap').value) || 0, transport: document.getElementById('aw-trans').value, contactEmail: document.getElementById('aw-email').value, contactPhone: document.getElementById('aw-phone').value };
    } else if (tabName === 'user') {
        endpoint = API + '/users';
        payload = { userId: 0, firstName: document.getElementById('au-fname').value, secondName: document.getElementById('au-sname').value, email: document.getElementById('au-email').value, passwordHash: document.getElementById('au-pass').value, organisation: document.getElementById('au-org').value, role: document.getElementById('au-role').value };
    } else if (tabName === 'partner') {
        endpoint = API + '/partners';
        payload = { partnerId: 0, organisation: document.getElementById('ap-org').value, contactName: document.getElementById('ap-contact').value, address: document.getElementById('ap-addr').value, email: document.getElementById('ap-email').value, phone: document.getElementById('ap-phone').value };
    } else if (tabName === 'tp') {
        endpoint = API + '/transport';
        payload = { tpId: 0, tpName: document.getElementById('at-name').value, tpLocation: document.getElementById('at-loc').value, tpEmail: document.getElementById('at-email').value, tpPhone: document.getElementById('at-phone').value };
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
        alert('Error adding item: ' + err.message);
    }
};

// Hook into ALL "Add" buttons on the page
document.addEventListener('click', function(e) {
    if (e.target && e.target.tagName === 'BUTTON' && e.target.innerText.trim() === 'Add') {
        e.preventDefault();
        e.stopPropagation();
        showAdminAddModal();
    }
});
"""

with open('frontend/admin.js', 'w') as f:
    f.write(js_code)

# 2. Clean up index.html
with open('frontend/index.html', 'r') as f:
    content = f.read()

# Remove any previously broken inline admin scripts
content = re.sub(r'<script>\s*// --- ADMIN PAGE DYNAMIC ADD FUNCTIONALITY ---.*?</script>', '', content, flags=re.DOTALL)
content = re.sub(r'<script>\s*function showAdminAddModal.*?</script>', '', content, flags=re.DOTALL)

# Inject the external script reference safely
if '<script src="admin.js"></script>' not in content:
    if '</body>' in content:
        content = content.replace('</body>', '<script src="admin.js"></script>\n</body>')
    else:
        content += '\n<script src="admin.js"></script>'

with open('frontend/index.html', 'w') as f:
    f.write(content)

print("✅ Created admin.js and safely linked it. Stray text should be gone.")
