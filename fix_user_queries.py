import re

with open('backend/src/DB.hs', 'r') as f:
    content = f.read()

# 1. Fix getUsers (around line 31)
content = content.replace(
    'return [ User (fromIntegral i) fn sn em org rl | (i::Int64, fn, sn, em, org, rl) <- rows ]',
    'return [ User (fromIntegral i) fn sn em ph org rl | (i::Int64, fn, sn, em, ph, org, rl) <- rows ]'
)

# 2. Fix getUserByEmail / loginUser (around line 126)
content = content.replace(
    'return $ listToMaybe [ User (fromIntegral i) fn sn e o r | (i::Int64, fn, sn, e, o, r) <- rows ]',
    'return $ listToMaybe [ User (fromIntegral i) fn sn e ph o r | (i::Int64, fn, sn, e, ph, o, r) <- rows ]'
)

# 3. Ensure the SQL queries actually select the password_hash column
content = content.replace(
    'SELECT id, first_name, second_name, email, organisation, role FROM users',
    'SELECT id, first_name, second_name, email, password_hash, organisation, role FROM users'
)
content = content.replace(
    'SELECT id, first_name, second_name, email, organisation, role FROM users WHERE email=?',
    'SELECT id, first_name, second_name, email, password_hash, organisation, role FROM users WHERE email=?'
)

with open('backend/src/DB.hs', 'w') as f:
    f.write(content)

print("✅ Fixed User constructors and SQL queries to include password_hash.")
