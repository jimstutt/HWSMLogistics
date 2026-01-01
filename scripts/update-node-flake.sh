#!/bin/bash
set -e
echo "🔧 Updating Node.js in flake.nix..."
cd ~/Dev/NGOL-D
if grep -q "nodejs_20" flake.nix; then
  sed -i 's/nodejs_20/nodejs_22/g' flake.nix
  echo "✅ flake.nix updated to Node.js 22"
else
  echo "ℹ️ flake.nix already uses Node.js 22"
fi
