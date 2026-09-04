#!/usr/bin/env bash
set -e

echo "🧹 Starting HWSMLogistics Cleanup based on HRSM-TechSpec..."
echo "---------------------------------------------------------"

# 1. Remove Legacy Node.js/React Frontend & Backend
echo "🗑️  Removing legacy Node.js/React directories (App/ and Backend/)..."
rm -rf ./App
rm -rf ./Backend

# 2. Remove Node.js artifacts
echo "🗑️  Removing Node.js package files and modules..."
rm -f ./package.json
rm -f ./package-lock.json
rm -f ./yarn.lock
rm -f ./pnpm-lock.yaml
rm -rf ./node_modules

# 3. Remove Haskell/Nix build artifacts
echo "🗑️  Removing Haskell (Cabal) and Nix build artifacts..."
rm -rf ./dist-newstyle
rm -rf ./result
rm -rf ./backend/src-bin
rm -rf ./frontend/dist
rm -rf ./common/dist

# 4. Remove old database data
echo "🗑️  Removing old MariaDB 10.11 data directory..."
rm -rf ./data/mariadb-1011

echo "---------------------------------------------------------"
echo "✅ Cleanup complete!"
echo ""
echo "Your project structure now aligns with the HRSM-TechSpec:"
echo "  ├── common/    (Shared Haskell Servant types & logic)"
echo "  ├── frontend/  (Pure Haskell WASM frontend)"
echo "  ├── backend/   (Haskell Servant backend & MariaDB persistence)"
echo "  ├── nix/       (Nix derivations and overlays)"
echo "  ├── data/      (Active MariaDB data)"
echo "  └── flake.nix  (Nix flake definition)"
