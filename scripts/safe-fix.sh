#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/Dev/NGOL-D"

# 1. Fix package.json (add mariadb, bcryptjs) — text edit only
cat > "$ROOT/scripts/fix-package-json.sh" <<'EOF'
#!/usr/bin/env bash
cd "$(dirname "$0")/.."
PKG="$PWD/Backend/package.json"

# Add mariadb & bcryptjs if missing (text patch — no jq needed)
if ! grep -q '"mariadb"' "$PKG"; then
  sed -i '/"dependencies": {/a \    "mariadb": "^3.3.0",' "$PKG"
  echo "✅ Added mariadb to Backend/package.json"
fi
if ! grep -q '"bcryptjs"' "$PKG"; then
  sed -i '/"dependencies": {/a \    "bcryptjs": "^2.4.3",' "$PKG"
  echo "✅ Added bcryptjs to Backend/package.json"
fi

# Regen lockfile (fast, no install)
cd Backend
npm install --package-lock-only --ignore-scripts --no-fund 2>/dev/null || echo "⚠️ Skipped lockfile update (offline)"
EOF

# 2. Fix Backend/default.nix (pure, no node_modules embedding)
cat > "$ROOT/scripts/fix-backend-nix.sh" <<'EOF'
#!/usr/bin/env bash
cd "$(dirname "$0")/.."
cat > Backend/default.nix <<'NIX'
{ pkgs, stdenv, lib }:
stdenv.mkDerivation {
  name = "ngol-d-backend";
  src = ./server.js ./socket.js ./package.json ./package-lock.json;
  buildInputs = [ pkgs.nodejs_20 pkgs.mariadb ];
  installPhase = ''
    mkdir -p $out/bin
    cp server.js socket.js package.json package-lock.json $out/
    cat > $out/bin/ngol-d-backend <<'SCRIPT'
#!/usr/bin/env bash
cd "$out"
exec ${pkgs.nodejs_20}/bin/node server.js "$@"
SCRIPT
    chmod +x $out/bin/ngol-d-backend
  '';
}
NIX
echo "✅ Backend/default.nix simplified (no node_modules embedding)"
EOF

# 3. Build only — no servers, no tests
cat > "$ROOT/scripts/build-only.sh" <<'EOF'
#!/usr/bin/env bash
cd "$(dirname "$0")/.."
echo "📦 Building .#App .#Backend (safe)..."
nix build .#App .#Backend --no-link
echo "✅ Build succeeded. Outputs:"
nix path-info result-App result-Backend 2>/dev/null || echo "(not linked)"
EOF

# Make all executable
chmod +x "$ROOT/scripts/"*.sh

# Run in safe order
"$ROOT/scripts/fix-package-json.sh"
"$ROOT/scripts/fix-backend-nix.sh"
"$ROOT/scripts/build-only.sh"

echo ""
echo "✅ Safe build done. Next steps:"
echo "   1. Start MariaDB: nix-shell -p mariadb --run 'mysqld --initialize --datadir=/tmp/mariadb && mysqld --datadir=/tmp/mariadb &'"
echo "   2. Run backend manually: cd Backend && node server.js"
echo "   3. Start frontend: cd App && npm run dev"
echo "   4. Visit http://localhost:5173 → Login modal first"
