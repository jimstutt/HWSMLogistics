#!/usr/bin/env bash
# ~/Dev/NGOL-D/scripts/start-servers.sh
# Spec: NGOLTechSpec.md — Production implementation
# - MariaDB 10.11 only
# - Socket.IO real-time
# - Login.vue first
# - No SQLite/mongo
set -euo pipefail

echo "🚀 Starting NGOL-D Production Stack"

# 1. Ensure MariaDB is ready (system or Nix)
./scripts/start-mariadb.sh

# 2. Start Backend (production mode)
echo "📡 Starting Backend..."
cd Backend
nix develop --command bash -c "
  export NODE_ENV=production
  export PORT=3000
  export MARIADB_HOST=127.0.0.1
  export MARIADB_PORT=3306
  export MARIADB_USER=ngol
  export MARIADB_PASSWORD=ngol
  export MARIADB_DATABASE=NGOL_D
  export JWT_SECRET='ngol-d-prod-jwt-secret-2026'
  node server.js
" &
BACKEND_PID=$!
cd ..

# 3. Wait for health check
for i in {1..30}; do
  if curl -sf http://localhost:3000/api/health | grep -q '"status":"ok"'; then
    echo "✅ Backend healthy"
    break
  fi
  echo "⏳ Waiting for backend... ($i/30)"
  sleep 1
done

# 4. Start Frontend (production build served)
echo "🌐 Building & Serving Frontend..."
cd App
nix build .#App
nix run .#frontend-prod &
FRONTEND_PID=$!
cd ..

echo -e "\n✅ NGOL-D Production Ready:"
echo "   🔒 Login: http://localhost:8080 (Login.vue first)"
echo "   🏥 Health: http://localhost:3000/api/health"
echo "   📱 Real-time: Socket.IO enabled"
echo ""
echo "   🔥 Ctrl+C to stop all servers"
wait $BACKEND_PID $FRONTEND_PID 2>/dev/null || true
