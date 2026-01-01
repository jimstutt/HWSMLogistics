#!/bin/bash
set -e
echo "🔧 Updating Node.js in App/default.nix..."
cd ~/Dev/NGOL-D/App
if grep -q "nodejs_20" default.nix; then
  sed -i 's/nodejs_20/nodejs_22/g' default.nix
  echo "✅ App/default.nix updated to Node.js 22"
else
  echo "ℹ️ App/default.nix already uses Node.js 22"
fi
