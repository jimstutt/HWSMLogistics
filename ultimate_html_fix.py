import re
from html.parser import HTMLParser

with open('frontend/index.html', 'r') as f:
    content = f.read()

# 1. AGGRESSIVE HTML SANITIZER
# Uses Python's HTMLParser to safely remove any stray JS text outside of <script> tags
class Cleaner(HTMLParser):
    def __init__(self):
        super().__init__()
        self.result = []
        self.in_script = False
        self.in_style = False
        
    def handle_starttag(self, tag, attrs):
        if tag == 'script': self.in_script = True
        if tag == 'style': self.in_style = True
        # Reconstruct the tag safely
        attr_str = ' '.join([f'{k}="{v}"' if v is not None else k for k, v in attrs])
        self.result.append(f'<{tag} {attr_str}>')
        
    def handle_endtag(self, tag):
        if tag == 'script': self.in_script = False
        if tag == 'style': self.in_style = False
        self.result.append(f'</{tag}>')
        
    def handle_data(self, data):
        if self.in_script or self.in_style:
            self.result.append(data) # Keep JS/CSS intact
        else:
            # If it's HTML text, drop it if it contains JS syntax
            if not re.search(r'(=>|fetch\(|document\.|console\.|localStorage|\.then\(|function |const |let |var )', data):
                self.result.append(data)

cleaner = Cleaner()
cleaner.feed(content)
content = ''.join(cleaner.result)
print("✅ Stray text completely sanitized from HTML body.")

# 2. FIX THE ADMIN ADD BUTTON
# Find the Add button in the Admin section and force it to use our custom function
content = re.sub(r'(<button[^>]*>Add</button>)', r'<button onclick="showCustomAdminAdd()">Add</button>', content)

# 3. DELETE ANY EXISTING BROKEN ADMIN MODALS
content = re.sub(r'<div[^>]*id="mod-admin-add"[^>]*>.*?</div>', '', content, flags=re.DOTALL)
content = re.sub(r'<div[^>]*id="admin-add-modal"[^>]*>.*?</div>', '', content, flags=re.DOTALL)

# 4. INJECT THE CUSTOM ADMIN MODAL SCRIPT
custom_script = """
<script>
function showCustomAdminAdd() {
    const activeTab = document.querySelector('#admin .tab.active');
    let tabText = activeTab ? activeTab.innerText.trim().toLowerCase() : '';
    
    let title = 'Add Item';
    let fields = '';
    const style = 'width:100%; margin-bottom:8px; padding:8px; border:1px solid #ccc; border-radius:4px; box-sizing:border-box;';

    if (tabText.includes('warehouse')) {
        title = 'Add Warehouse';
        fields = `<input type="text" id="aw-loc" placeholder="Location" style="${style}">
                  <input type="number" id="aw-cap" placeholder="Capacity" style="${style}">
                  <input type="text" id="aw-trans" placeholder="Transport" style="${style}">
                  <input type="email" id="aw-email" placeholder="Email" style="${style}">
                  <input type="text" id="aw-phone" placeholder="Phone" style="${style}">`;
    } else if (tabText.includes('transport')) {
        title = 'Add Transport Provider';
        fields = `<input type="text" id="at-name" placeholder="Name" style="${style}">
                  <input type="text" id="at-loc" placeholder="Location" style="${style}">
                  <input type="email" id="at-email" placeholder="Email" style="${style}">
                  <input type="text" id="at-phone" placeholder="Phone" style="${style}">`;
    } else if (tabText.includes('partner')) {
        title = 'Add Partner';
        fields = `<input type="text" id="ap-org" placeholder="Organisation" style="${style}">
                  <input type="text" id="ap-contact" placeholder="Contact Name" style="${style}">
                  <input type="text" id="ap-addr" placeholder="Address" style="${style}">
                  <input type="email" id="ap-email" placeholder="Email" style="${style}">
                  <input type="text" id="ap-phone" placeholder="Phone" style="${style}">`;
    } else {
        title = 'Add User';
        fields = `<input type="text" id="au-fname" placeholder="First Name" style="${style}">
                  <input type="text" id="au-sname" placeholder="Second Name" style="${style}">
                  <input type="email" id="au-email" placeholder="Email" style="${style}">
                  <input type="password" id="au-pass" placeholder="Password" style="${style}">
                  <input type="text" id="au-org" placeholder="Organisation" style="${style}">
                  <input type="text" id="au-role" placeholder="Role" style="${style}">`;
    }

    const modal = document.createElement('div');
    modal.id = 'custom-admin-modal';
    modal.style.cssText = 'position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); display:flex; align-items:center; justify-content:center; z-index:1000;';
    modal.innerHTML = `<div style="background:white; padding:20px; border-radius:8px; width:300px; box-shadow:0 4px 6px rgba(0,0,0,0.1);">
        <h3 style="margin-top:0;">${title}</h3>
        <div id="custom-admin-fields">${fields}</div>
        <button onclick="saveCustomAdminItem()" style="margin-top:10px; background:#28a745; color:white; border:none; padding:8px 16px; border-radius:4px; cursor:pointer; width:48%;">Save</button>
        <button onclick="document.getElementById('custom-admin-modal').remove()" style="margin-top:10px; background:#dc3545; color:white; border:none; padding:8px 16px; border-radius:4px; cursor:pointer; width:48%;">Cancel</button>
    </div>`;
    document.body.appendChild(modal);
}

window.saveCustomAdminItem = async function() {
    const activeTab = document.querySelector('#admin .tab.active');
    let tabText = activeTab ? activeTab.innerText.trim().toLowerCase() : '';
    let payload = {};
    let endpoint = '';

    if (tabText.includes('warehouse')) {
        endpoint = API + '/warehouses';
        payload = { warehouseId: 0, location: document.getElementById('aw-loc').value, capacity: parseInt(document.getElementById('aw-cap').value) || 0, transport: document.getElementById('aw-trans').value, contactEmail: document.getElementById('aw-email').value, contactPhone: document.getElementById('aw-phone').value };
    } else if (tabText.includes('transport')) {
        endpoint = API + '/transport';
        payload = { tpId: 0, tpName: document.getElementById('at-name').value, tpLocation: document.getElementById('at-loc').value, tpEmail: document.getElementById('at-email').value, tpPhone: document.getElementById('at-phone').value };
    } else if (tabText.includes('partner')) {
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
            if (typeof loadAdmin === 'function') loadAdmin();
            alert('Item added successfully!');
        } else {
            alert('Failed to add item: HTTP ' + res.status);
        }
    } catch (err) {
        alert('Error: ' + err.message);
    }
};
</script>
"""

if '</body>' in content:
    content = content.replace('</body>', custom_script + '\n</body>')
else:
    content += '\n' + custom_script

with open('frontend/index.html', 'w') as f:
    f.write(content)

print("✅ HTML parsed, sanitized, and Admin Add button fixed.")
