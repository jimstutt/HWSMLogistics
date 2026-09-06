import re

with open('backend/backend.cabal', 'r') as f:
    lines = f.readlines()

new_lines = []
skip_next = 0
for i, line in enumerate(lines):
    if skip_next > 0:
        skip_next -= 1
        continue
    
    # Skip the malformed build-depends block
    if line.strip().startswith('build-depends:,'):
        # Skip this line and the next two lines (time, , http-types)
        skip_next = 2
        continue
        
    new_lines.append(line)

content = "".join(new_lines)

# Ensure 'time' is in the main build-depends list
if ', time' not in content:
    content = content.replace(', stm', ', stm\n                  , time')

with open('backend/backend.cabal', 'w') as f:
    f.write(content)

print("✅ Cabal file cleaned and 'time' added correctly.")
