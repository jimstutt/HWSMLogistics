with open('backend/src/DB.hs', 'r') as f:
    content = f.read()

# 1. Fix the SQL query to include password_hash
content = content.replace(
    'INSERT INTO users (first_name, second_name, email, organisation, role) VALUES (?, ?, ?, ?, ?)',
    'INSERT INTO users (first_name, second_name, email, password_hash, organisation, role) VALUES (?, ?, ?, ?, ?, ?)'
)

# 2. Fix the parameters tuple to include u.passwordHash
content = content.replace(
    '(u.firstName, u.secondName, u.email, u.organisation, u.role)',
    '(u.firstName, u.secondName, u.email, u.passwordHash, u.organisation, u.role)'
)

with open('backend/src/DB.hs', 'w') as f:
    f.write(content)

print("✅ Fixed createUser SQL and parameters to include password_hash.")
