with open('frontend/index.html', 'r') as f:
    content = f.read()

# 1. Remove the broken JavaScript at the end
# Find and remove everything from "function doLogin" onwards that's broken
import re
content = re.sub(r'function doLogin\s*\n\s*\}\)\s*\n.*?WS: Disconnected', 'WS: Connected', content, flags=re.DOTALL)

# 2. Ensure proper closing tags
if '</body>' not in content:
    content += '\n</body>'
if '</html>' not in content:
    content += '\n</html>'

# 3. Add the complete, working JavaScript before </body>
complete_script = '''
<script>
const API = 'http://localhost:3000/api';
let mapInstance = null;

// Login
function doLogin() {
    fetch(API + '/auth/login', {
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
        } else {
            const lerr = document.getElementById('lerr');
            if (lerr) lerr.textContent = 'Invalid credentials';
        }
    })
    .catch(err => {
        console.error('Login failed:', err);
        const lerr = document.getElementById('lerr');
        if (lerr) lerr.textContent = 'Login error: ' + err.message;
    });
}

// Navigation
function go(page) {
    window.location.hash = page;
    location.reload();
}

// Admin Tab Selection
let adminType = 'user';
function adminTab(t) {
    adminType = t;
    document.querySelectorAll('#admin .tab').forEach(tab => tab.classList.remove('active'));
    event.target.classList.add('active');
    loadAdmin();
}

// Load Admin Data
async function loadAdmin() {
    let endpoint = '';
    if (adminType === 'user') endpoint = API + '/users';
    else if (adminType === 'partner') endpoint = API + '/partners';
    else if (adminType === 'wh') endpoint = API + '/warehouses';
    else if (adminType === 'tp') endpoint = API + '/transport';
    
    try {
        const res = await fetch(endpoint);
        const data = await res.json();
        const listEl = document.getElementById('admin-list');
        if (listEl) {
            if (data.length === 0) {
                listEl.innerHTML = '<p style="color:#888; padding:20px;">No items found</p>';
            } else {
                listEl.innerHTML = data.map(item => {
                    if (adminType === 'user') return '<div class="list-item">' + item.firstName + ' ' + item.secondName + ' (' + item.email + ')</div>';
                    if (adminType === 'partner') return '<div class="list-item">' + item.organisation + ' - ' + item.contactName + '</div>';
                    if (adminType === 'wh') return '<div class="list-item">' + item.location + ' (Cap: ' + item.capacity + ')</div>';
                    if (adminType === 'tp') return '<div class="list-item">' + item.tpName + ' (' + item.tpLocation + ')</div>';
                    return '<div class="list-item">Item</div>';
                }).join('');
            }
        }
    } catch (err) {
        console.error('Error loading admin data:', err);
    }
}

// Custom Admin Add Modal
function showCustomAdminAdd() {
    const tabText = adminType;
    let title = 'Add Item';
    let fields = '';
    const style = 'width:100%; margin-bottom:8px; padding:8px; border:1px solid #ccc; border-radius:4px; box-sizing:border-box;';

    if (tabText === 'wh') {
        title = 'Add Warehouse';
        fields = '<input type="text" id="aw-loc" placeholder="Location" style="' + style + '">' +
                 '<input type="number" id="aw-cap" placeholder="Capacity" style="' + style + '">' +
                 '<input type="text" id="aw-trans" placeholder="Transport" style="' + style + '">' +
                 '<input type="email" id="aw-email" placeholder="Email" style="' + style + '">' +
                 '<input type="text" id="aw-phone" placeholder="Phone" style="' + style + '">';
    } else if (tabText === 'tp') {
        title = 'Add Transport Provider';
        fields = '<input type="text" id="at-name" placeholder="Name" style="' + style + '">' +
                 '<input type="text" id="at-loc" placeholder="Location" style="' + style + '">' +
                 '<input type="email" id="at-email" placeholder="Email" style="' + style + '">' +
                 '<input type="text" id="at-phone" placeholder="Phone" style="' + style + '">';
    } else if (tabText === 'partner') {
        title = 'Add Partner';
        fields = '<input type="text" id="ap-org" placeholder="Organisation" style="' + style + '">' +
                 '<input type="text" id="ap-contact" placeholder="Contact Name" style="' + style + '">' +
                 '<input type="text" id="ap-addr" placeholder="Address" style="' + style + '">' +
                 '<input type="email" id="ap-email" placeholder="Email" style="' + style + '">' +
                 '<input type="text" id="ap-phone" placeholder="Phone" style="' + style + '">';
    } else {
        title = 'Add User';
        fields = '<input type="text" id="au-fname" placeholder="First Name" style="' + style + '">' +
                 '<input type="text" id="au-sname" placeholder="Second Name" style="' + style + '">' +
                 '<input type="email" id="au-email" placeholder="Email" style="' + style + '">' +
                 '<input type="password" id="au-pass" placeholder="Password" style="' + style + '">' +
                 '<input type="text" id="au-org" placeholder="Organisation" style="' + style + '">' +
                 '<input type="text" id="au-role" placeholder="Role" style="' + style + '">';
    }

    const modal = document.createElement('div');
    modal.id = 'custom-admin-modal';
    modal.style.cssText = 'position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); display:flex; align-items:center; justify-content:center; z-index:1000;';
    modal.innerHTML = '<div style="background:white; padding:20px; border-radius:8px; width:300px; box-shadow:0 4px 6px rgba(0,0,0,0.1);">' +
        '<h3 style="margin-top:0;">' + title + '</h3>' +
        '<div id="custom-admin-fields">' + fields + '</div>' +
        '<button onclick="saveCustomAdminItem()" style="margin-top:10px; background:#28a745; color:white; border:none; padding:8px 16px; border-radius:4px; cursor:pointer; width:48%;">Save</button>' +
        '<button onclick="document.getElementById(\\'custom-admin-modal\\').remove()" style="margin-top:10px; background:#dc3545; color:white; border:none; padding:8px 16px; border-radius:4px; cursor:pointer; width:48%;">Cancel</button>' +
    '</div>';
    document.body.appendChild(modal);
}

window.saveCustomAdminItem = async function() {
    const tabText = adminType;
    let payload = {};
    let endpoint = '';

    if (tabText === 'wh') {
        endpoint = API + '/warehouses';
        payload = { warehouseId: 0, location: document.getElementById('aw-loc').value, capacity: parseInt(document.getElementById('aw-cap').value) || 0, transport: document.getElementById('aw-trans').value, contactEmail: document.getElementById('aw-email').value, contactPhone: document.getElementById('aw-phone').value };
    } else if (tabText === 'tp') {
        endpoint = API + '/transport';
        payload = { tpId: 0, tpName: document.getElementById('at-name').value, tpLocation: document.getElementById('at-loc').value, tpEmail: document.getElementById('at-email').value, tpPhone: document.getElementById('at-phone').value };
    } else if (tabText === 'partner') {
        endpoint = API + '/partners';
        payload = { partnerId: 0, organisation: document.getElementById('ap-org').value, contactName: document.getElementById('ap-contact').value, address: document.getElementById('ap-addr').value, email: document.getElementById('ap-email').value, phone: document.getElementById('ap-phone').value };
    } else {
        endpoint = API + '/users';
        payload = { userId: 0, firstName: document.getElementById('au-fname').value, secondName: document.getElementById('au-sname').value, email: document.getElementById('au-email').value, passwordHash: document.getElementById('au-pass').value, organisation: document.getElementById('au-org').value, role: document.getElementById('au-role').value };
    }

    try {
        const res = await fetch(endpoint, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) });
        if (res.ok) {
            document.getElementById('custom-admin-modal').remove();
            loadAdmin();
            alert('Item added successfully!');
        } else {
            alert('Failed to add item: HTTP ' + res.status);
        }
    } catch (err) {
        alert('Error: ' + err.message);
    }
};

// Initialize on load
window.addEventListener('load', function() {
    const hash = window.location.hash.substring(1) || 'dashboard';
    if (hash === 'admin') {
        const adminSection = document.getElementById('admin');
        if (adminSection) adminSection.classList.add('active');
    }
});
</script>
'''

# Insert before </body>
if '</body>' in content:
    content = content.replace('</body>', complete_script + '\n</body>')
else:
    content += complete_script

with open('frontend/index.html', 'w') as f:
    f.write(content)

print("✅ Fixed syntax error and added complete working JavaScript.")
