import re

with open('backend/src/DB.hs', 'r') as f:
    content = f.read()

# 1. Fix the SQL query to include password_hash
content = content.replace(
    'INSERT INTO users (email, first_name, second_name, organisation, role) VALUES (?, ?, ?, ?, ?)',
    'INSERT INTO users (email, password_hash, first_name, second_name, organisation, role) VALUES (?, ?, ?, ?, ?, ?)'
)

# 2. Fix the parameters tuple (using standard record accessors)
content = re.sub(
    r'\(email u,\s*firstName u,\s*secondName u,\s*organisation u,\s*role u\)',
    r'(email u, passwordHash u, firstName u, secondName u, organisation u, role u)',
    content
)

# 3. Fallback: Fix the parameters tuple (using prefixed accessors)
content = re.sub(
    r'\(userEmail u,\s*userFirstName u,\s*userSecondName u,\s*userOrganisation u,\s*userRole u\)',
    r'(userEmail u, userPasswordHash u, userFirstName u, userSecondName u, userOrganisation u, userRole u)',
    content
)

with open('backend/src/DB.hs', 'w') as f:
    f.write(content)

print("✅ Fixed createUser to include password_hash.")
