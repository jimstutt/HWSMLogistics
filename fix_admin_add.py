with open('frontend/index.html', 'r') as f:
    content = f.read()

admin_script = """
<script>
// --- ADMIN PAGE DYNAMIC ADD FUNCTIONALITY ---
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
    
    let modalHTML = '<div id="admin-add-modal" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); display:flex; align-items:center; justify-content:center; z-index:1000;">';
    modalHTML += '<div style="background:white; padding:20px; border-radius:8px; width:300px; max-height:80vh; overflow-y:auto; box-shadow:0 4px 6px rgba(0,0,0,0.1);">';
    modalHTML += '<h3 id="admin-add-title" style="margin-top:0;">Add Item</h3>';
    modalHTML += '<div id="admin-add-fields"></div>';
    modalHTML += '<button onclick="saveAdminItem()" style="margin-top:10px; background:#28a745; color:white; border:none; padding:8px 16px; border-radius:4px; cursor:pointer;">Save</button>';
    modalHTML += '<button onclick="document.getElementById(\\'admin-add-modal\\').remove()" style="margin-top:10px; margin-left:10px; background:#dc3545; color:white; border:none; padding:8px 16px; border-radius:4px; cursor:pointer;">Cancel</button>';
    modalHTML += '</div></div>';
    
    document.body.insertAdjacentHTML('beforeend', modalHTML);
    
    const fieldsDiv = document.getElementById('admin-add-fields');
    const inputStyle = 'width:100%; margin-bottom:8px; padding:8px; border:1px solid #ccc; border-radius:4px; box-sizing:border-box;';
    
    if (tabName === 'wh') {
        document.getElementById('admin-add-title').innerText = 'Add Warehouse';
        fieldsDiv.innerHTML = `
            <input type="text" id="aw-loc" placeholder="Location (e.g., Nairobi, Kenya)" style="${inputStyle}">
            <input type="number" id="aw-cap" placeholder="Capacity" style="${inputStyle}">
            <input type="text" id="aw-trans" placeholder="Transport (e.g., Road)" style="${inputStyle}">
            <input type="email" id="aw-email" placeholder="Contact Email" style="${inputStyle}">
            <input type="text" id="aw-phone" placeholder="Contact Phone" style="${inputStyle}">
        `;
    } else if (tabName === 'user') {
        document.getElementById('admin-add-title').innerText = 'Add User';
        fieldsDiv.innerHTML = `
            <input type="text" id="au-fname" placeholder="First Name" style="${inputStyle}">
            <input type="text" id="au-sname" placeholder="Second Name" style="${inputStyle}">
            <input type="email" id="au-email" placeholder="Email" style="${inputStyle}">
            <input type="password" id="au-pass" placeholder="Password" style="${inputStyle}">
            <input type="text" id="au-org" placeholder="Organisation" style="${inputStyle}">
            <input type="text" id="au-role" placeholder="Role (e.g., admin)" style="${inputStyle}">
        `;
    } else if (tabName === 'partner') {
        document.getElementById('admin-add-title').innerText = 'Add Partner';
        fieldsDiv.innerHTML = `
            <input type="text" id="ap-org" placeholder="Organisation" style="${inputStyle}">
            <input type="text" id="ap-contact" placeholder="Contact Name" style="${inputStyle}">
            <input type="text" id="ap-addr" placeholder="Address" style="${inputStyle}">
            <input type="email" id="ap-email" placeholder="Email" style="${inputStyle}">
            <input type="text" id="ap-phone" placeholder="Phone" style="${inputStyle}">
        `;
    } else if (tabName === 'tp') {
        document.getElementById('admin-add-title').innerText = 'Add Transport Provider';
        fieldsDiv.innerHTML = `
            <input type="text" id="at-name" placeholder="Name" style="${inputStyle}">
            <input type="text" id="at-loc" placeholder="Location" style="${inputStyle}">
            <input type="email" id="at-email" placeholder="Email" style="${inputStyle}">
            <input type="text" id="at-phone" placeholder="Phone" style="${inputStyle}">
        `;
    }
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
        payload = {
            warehouseId: 0,
            location: document.getElementById('aw-loc').value,
            capacity: parseInt(document.getElementById('aw-cap').value) || 0,
            transport: document.getElementById('aw-trans').value,
            contactEmail: document.getElementById('aw-email').value,
            contactPhone: document.getElementById('aw-phone').value
        };
    } else if (tabName === 'user') {
        endpoint = API + '/users';
        payload = {
            userId: 0,
            firstName: document.getElementById('au-fname').value,
            secondName: document.getElementById('au-sname').value,
            email: document.getElementById('au-email').value,
            passwordHash: document.getElementById('au-pass').value,
            organisation: document.getElementById('au-org').value,
            role: document.getElementById('au-role').value
        };
    } else if (tabName === 'partner') {
        endpoint = API + '/partners';
        payload = {
            partnerId: 0,
            organisation: document.getElementById('ap-org').value,
            contactName: document.getElementById('ap-contact').value,
            address: document.getElementById('ap-addr').value,
            email: document.getElementById('ap-email').value,
            phone: document.getElementById('ap-phone').value
        };
    } else if (tabName === 'tp') {
        endpoint = API + '/transport';
        payload = {
            tpId: 0,
            tpName: document.getElementById('at-name').value,
            tpLocation: document.getElementById('at-loc').value,
            tpEmail: document.getElementById('at-email').value,
            tpPhone: document.getElementById('at-phone').value
        };
    }

    try {
        const res = await fetch(endpoint, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });
        if (res.ok) {
            document.getElementById('admin-add-modal').remove();
            if (typeof loadAdmin === 'function') loadAdmin();
            alert('Item added successfully!');
        } else {
            const errText = await res.text();
            alert('Failed to add item: HTTP ' + res.status + '\\n' + errText);
        }
    } catch (err) {
        console.error('Error adding item:', err);
        alert('Error adding item: ' + err.message);
    }
};

// Hook into the Admin "Add" button
document.addEventListener('click', function(e) {
    if (e.target && e.target.innerText === 'Add' && e.target.closest('#admin')) {
        e.preventDefault();
        e.stopPropagation();
        showAdminAddModal();
    }
});
</script>
"""

if '</body>' in content:
    content = content.replace('</body>', admin_script + '\n</body>')
else:
    content += '\n' + admin_script

with open('frontend/index.html', 'w') as f:
    f.write(content)

print("✅ Admin Add functionality injected.")
