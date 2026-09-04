#!/usr/bin/env bash
set -e

CABAL_FILE="backend/backend.cabal"

if [ ! -f "$CABAL_FILE" ]; then
    echo "❌ Error: $CABAL_FILE not found. Run from project root."
    exit 1
fi

echo "🔧 Patching $CABAL_FILE to include http-types..."

# Use Python (via Nix) for reliable multi-line .cabal editing
nix shell nixpkgs#python3 --command python3 - << 'PYTHON_SCRIPT'
import re

file_path = "backend/backend.cabal"
with open(file_path, "r") as f:
    content = f.read()

if "http-types" in content:
    print("ℹ️  http-types is already in backend.cabal.")
else:
    # Find the executable backend section and inject http-types into its build-depends
    pattern = r'(executable backend\s+hs-source-dirs.*?build-depends:\s*\n)'
    replacement = r'\1        http-types,\n'
    new_content = re.sub(pattern, replacement, content, flags=re.DOTALL)
    
    if new_content == content:
        # Fallback: append to end of file (Cabal parser accepts this)
        with open(file_path, "a") as f:
            f.write("\nbuild-depends:\n    , http-types\n")
        print("✅ Appended http-types to backend.cabal (fallback).")
    else:
        with open(file_path, "w") as f:
            f.write(new_content)
        print("✅ Successfully inserted http-types into executable backend dependencies.")
PYTHON_SCRIPT

echo ""
echo "💡 CRITICAL NEXT STEP:"
echo "Run 'git add backend/backend.cabal' so Nix can see the updated dependency!"
