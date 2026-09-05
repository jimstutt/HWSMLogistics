#!/usr/bin/env bash
set -e

echo "🔧 Step 1: Freeing port 3000..."
pkill -f "backend" || true
fuser -k 3000/tcp 2>/dev/null || true
sleep 1
echo "✅ Port 3000 is free."

echo "🔧 Step 2: Removing incompatible 'mysql' Haskell package from backend.cabal..."
# Remove standalone 'mysql' or ', mysql' from build-depends, but leave 'mysql-simple' intact
sed -i -E 's/^[[:space:]]*,?[[:space:]]*mysql[[:space:]]*$//' backend/backend.cabal
sed -i -E 's/,[[:space:]]*mysql([[:space:]]|$)/\1/g' backend/backend.cabal
echo "✅ Removed 'mysql' from backend.cabal."

echo "🔧 Step 3: Checking flake.nix for required C libraries..."
if grep -q "pkgs.pcre" flake.nix && grep -q "pkgs.mariadb-connector-c" flake.nix; then
    echo "✅ C libraries already present in flake.nix."
else
    echo "⚠️ ACTION REQUIRED: You must add C libraries to flake.nix."
    echo "Open flake.nix and add 'pkgs.pcre' and 'pkgs.mariadb-connector-c' to the buildInputs of your backend package or devShell."
    echo ""
    echo "Example snippet to add inside your backend package or devShell definition:"
    echo "  buildInputs = [ pkgs.pcre pkgs.mariadb-connector-c ]; # <-- Add this"
fi

echo ""
echo "💡 Final Steps:"
echo "1. Update flake.nix as instructed above."
echo "2. git add backend/backend.cabal flake.nix"
echo "3. nix build .#backend"
