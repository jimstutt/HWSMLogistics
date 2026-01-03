#!/usr/bin/env bash
# ~/Dev/NGOL-D/scripts/fix-start-servers.sh
# Spec-compliant: NGOLTechSpec.md — Development startup (not production build)
cat > ~/Dev/NGOL-D/scripts/start-servers.sh <<'EOF'
#!/usr/bin/env bash
# ~/Dev/NGOL-D/scripts/start-servers.sh
# Development startup (NGOLTechSpec.md § Development Startup)
set -euo pipefail

echo "🚀 Starting NGOL-D Development Stack"

# 1. Ensure MariaDB is ready
./scripts/start-mariadb.sh

# 2. Start Backend (dev)
echo "📡 Starting Backend..."
cd Backend
nix --no-warn-dirty develop --command bash -c "
  export NODE_ENV=development
  export PORT=3000
  export MARIADB_HOST=127.0.0.1
  export MARIADB_PORT=3306
  export MARIADB_USER=ngol
  export MARIADB_PASSWORD=ngol
  export MARIADB_DATABASE=NGOL_D
  node server.js
" &
BACKEND_PID=$!
cd ..

# 3. Wait for health
for i in {1..20}; do
  if curl -sf http://localhost:3000/api/health | grep -q '"status":"ok"'; then
    echo "✅ Backend healthy"
    break
  fi
  sleep 1
done

# 4. Start Frontend (dev — not build!)
echo "🌐 Starting Frontend (dev)..."
cd App
nix --no-warn-dirty develop .#frontend --command npm run dev &
FRONTEND_PID=$!
cd ..

echo -e "\n✅ Ready:"
echo "   🔒 Login: http://localhost:5173 (Login.vue first)"
echo "   🏥 Health: http://localhost:3000/api/health"
wait $BACKEND_PID $FRONTEND_PID 2>/dev/null || true
EOF

chmod +x ~/Dev/NGOL-D/scripts/start-servers.sh
echo "✅ ~/Dev/NGOL-D/scripts/start-servers.sh updated (dev mode, no build hang)"
