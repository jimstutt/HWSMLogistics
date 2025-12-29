#!/usr/bin/env bash
# ~/Dev/NGOL-D/start-servers.sh
# Starts full NGOL-D stack (MariaDB + Backend + Frontend)
set -euo pipefail

# Start MariaDB
echo "🚀 Starting NGOL-D Full Stack..."
./start-mariadb.sh &
MARIADB_SETUP_PID=$!

# Wait for MariaDB
wait $MARIADB_SETUP_PID

# Start Backend (spec: localhost:3000/api/health → { status: 'ok', db: 'mariadb' })
echo "📡 Starting Backend..."
cd Backend
nix develop --command node server.js &
BACKEND_PID=$!
cd ..

# Wait for backend health check
for i in {1..15}; do
  if curl -sf http://localhost:3000/api/health | grep -q '"status":"ok"'; then
    break
  fi
  sleep 1
done

# Start Frontend (spec: localhost:5173 → Login.vue modal first)
echo "🌐 Starting Frontend..."
cd App
nix develop --command npm run dev &
FRONTEND_PID=$!
cd ..

# Verification
echo -e "\n✅ NGOL-D Full Stack Ready:"
echo "   🔒 Login: http://localhost:5173 (Login.vue modal first)"
echo "   🏥 Health: http://localhost:3000/api/health"
echo "   📊 Dashboard: http://localhost:5173 (after login)"
echo "   📱 Real-time: Socket.IO updates enabled"
echo ""
echo "   🔥 Ctrl+C to stop all servers"
wait $BACKEND_PID $FRONTEND_PID 2>/dev/null || true
