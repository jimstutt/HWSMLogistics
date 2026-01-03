#!/usr/bin/env bash
# ~/Dev/NGOL-D/scripts/upgrade-socketio.sh
# Spec: NGOLTechSpec.md — "Socket.IO 4.8.1"
set -euo pipefail

echo "🔧 Upgrading socket.io-client to 4.8.1 (spec-compliant)"
cd ~/Dev/NGOL-D/App

# Use nix shell to ensure node/npm version match
nix develop .#frontend --command bash -c "
  npm install socket.io-client@4.8.1
  echo '✅ socket.io-client upgraded to 4.8.1'
"

# Verify
grep '"socket.io-client"' package.json
