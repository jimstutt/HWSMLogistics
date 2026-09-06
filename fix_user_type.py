import re

# 1. Add passwordHash to the User type in Common.Types
with open('common/src/Common/Types.hs', 'r') as f:
    types_content = f.read()

if 'passwordHash :: Text' not in types_content:
    types_content = types_content.replace(
        ', email :: Text\n  , organisation :: Text',
        ', email :: Text\n  , passwordHash :: Text\n  , organisation :: Text'
    )
    with open('common/src/Common/Types.hs', 'w') as f:
        f.write(types_content)
    print("✅ Added passwordHash to User type.")

# 2. Update getUsers in DB.hs to fetch and map the password_hash
with open('backend/src/DB.hs', 'r') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    # Update the SQL query
    if 'SELECT id, first_name, second_name, email, organisation, role FROM users' in line:
        line = line.replace('email, organisation', 'email, password_hash, organisation')
    
    # Update the tuple type signature
    if ':: IO [(Int64, Text, Text, Text, Text, Text)]' in line:
        line = line.replace('(Int64, Text, Text, Text, Text, Text)', '(Int64, Text, Text, Text, Text, Text, Text)')
    
    # Update the list comprehension to include the new field
    if 'return [ User (fromIntegral i)' in line and 'ph' not in line:
        match = re.search(r'return \[ User \(fromIntegral i\) (\w+) (\w+) (\w+) (\w+) (\w+) \| \(i, (.*)\) <- rows \]', line)
        if match:
            v1, v2, v3, v4, v5 = match.group(1), match.group(2), match.group(3), match.group(4), match.group(5)
            new_tuple = f"i, {v1}, {v2}, {v3}, ph, {v4}, {v5}"
            new_user = f"User (fromIntegral i) {v1} {v2} {v3} ph {v4} {v5}"
            line = f"  return [ {new_user} | ({new_tuple}) <- rows ]\n"
            
    new_lines.append(line)

with open('backend/src/DB.hs', 'w') as f:
    f.writelines(new_lines)

print("✅ Updated getUsers to include password_hash.")
