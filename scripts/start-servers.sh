#!/usr/bin/env bash
# ~/Dev/NGOL-D/scripts/start-servers.sh
set -euo pipefail

echo "🚀 Starting NGOL-D Full Stack"

# Clear frontend auth state (enforce Login.vue first)
rm -f ~/.config/NGOL-D/* 2>/dev/null || true
echo "localStorage.clear();" | sqlite3 ~/.config/chromium/Default/Local\ Storage/leveldb/*.ldb 2>/dev/null || true

# 1. MariaDB (port 3306)
./scripts/start-mariadb.sh

# 2. Backend — explicit env (port 3306)
cd Backend
nix develop --command bash -c "
  export MARIADB_HOST=\${MARIADB_HOST:-127.0.0.1}
  export MARIADB_PORT=3306   # ← enforced
  export MARIADB_USER=\${MARIADB_USER:-ngol}
  export MARIADB_PASSWORD=\${MARIADB_PASSWORD:-ngol}
  export MARIADB_DATABASE=\${MARIADB_DATABASE:-NGOL_D}
  node server.js
" &
BACKEND_PID=$!
cd ..

# 3. Wait for health
for i in {1..30}; do
  if curl -sf http://localhost:3000/api/health | grep -q '"status":"ok"'; then
    echo "✅ Backend healthy"
    break
  fi
  echo "⏳ Waiting... ($i/30)"
  sleep 1
done

# 4. Frontend — clear Vite cache
cd App
rm -rf node_modules/.vite
nix develop --command npm run dev &
FRONTEND_PID=$!
cd ..

echo -e "\n✅ Ready:"
echo "   🔒 Login: http://localhost:5173 (Login.vue first)"
echo "   🏥 Health: http://localhost:3000/api/health"
wait $BACKEND_PID $FRONTEND_PID 2>/dev/null || true
