#!/bin/bash
set -e

echo "🔧 Updating Node.js version to 22.x for Vite compatibility..."
cd ~/Dev/NGOL-D

# Update flake.nix to use Node.js 22
if grep -q "nodejs_20" flake.nix; then
  sed -i 's/nodejs_20/nodejs_22/g' flake.nix
  echo "✅ flake.nix updated to use Node.js 22"
else
  echo "ℹ️ flake.nix already uses Node.js 22 or doesn't contain nodejs_20"
fi

# Update App/default.nix to use Node.js 22
if grep -q "nodejs_20" App/default.nix; then
  sed -i 's/nodejs_20/nodejs_22/g' App/default.nix
  echo "✅ App/default.nix updated to use Node.js 22"
else
  echo "ℹ️ App/default.nix already uses Node.js 22 or doesn't contain nodejs_20"
fi

# Update Backend/default.nix if it exists and contains nodejs_20
if [ -f "Backend/default.nix" ] && grep -q "nodejs_20" Backend/default.nix; then
  sed -i 's/nodejs_20/nodejs_22/g' Backend/default.nix
  echo "✅ Backend/default.nix updated to use Node.js 22"
elif [ -f "Backend/default.nix" ]; then
  echo "ℹ️ Backend/default.nix already uses Node.js 22 or doesn't contain nodejs_20"
fi

echo ""
echo "✨ Node.js version updated successfully"
echo "💡 Next step: Run './fix-npm-deps-hash.sh' to update the npm dependencies hash"
