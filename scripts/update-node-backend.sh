#!/bin/bash
set -e
echo "🔧 Updating Node.js in Backend/default.nix..."
cd ~/Dev/NGOL-D
if [ -f "Backend/default.nix" ]; then
  if grep -q "nodejs_20" Backend/default.nix; then
    sed -i 's/nodejs_20/nodejs_22/g' Backend/default.nix
    echo "✅ Backend/default.nix updated to Node.js 22"
  else
    echo "ℹ️ Backend/default.nix already uses Node.js 22"
  fi
else
  echo "ℹ️ Backend/default.nix not found - skipping"
fi
