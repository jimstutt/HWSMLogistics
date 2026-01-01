#!/bin/bash
set -e
echo "🔧 Rebuilding with Nix..."
cd ~/Dev/NGOL-D
nix build .#ngol-d-frontend
echo "✅ Nix build completed successfully"
