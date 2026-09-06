import glob
import re

# Find the cabal file in the backend directory (or root)
cabal_files = glob.glob('backend/*.cabal') + glob.glob('*.cabal')

if not cabal_files:
    print("❌ Could not find a .cabal file!")
else:
    for cf in cabal_files:
        with open(cf, 'r') as f:
            content = f.read()
        
        # Check if 'time' is already in the build-depends
        if re.search(r'\btime\b', content):
            print(f"ℹ️ 'time' already found in {cf}")
            continue
            
        # Safely inject 'time, ' right after 'build-depends:'
        new_content = re.sub(r'(build-depends:\s*)', r'\1time, ', content, count=1)
        
        with open(cf, 'w') as f:
            f.write(new_content)
        print(f"✅ Successfully added 'time' to {cf}")
