#!/bin/bash
# /home/jim/Dev/NGOL-D/scripts/start-servers.sh
set -euo pipefail

echo "🧹 Cleaning existing processes..."
pkill -f 'vite.*dev' 2>/dev/null || true
pkill -f 'node.*server.js' 2>/dev/null || true

# Optional: Double-check with lsof
echo "🔍 Verifying port cleanup..."
lsof -i :3001 -i :5173 2>/dev/null | grep -E "(node|vite)" && echo "⚠️  Ports still in use!" || echo "✅ Ports 3001/5173 free"

echo "🚀 Starting NGOLogisticsD..."

# Start Backend
echo "📦 Starting Backend (http://localhost:3001)..."
cd /home/jim/Dev/NGOL-D/Backend && npm run dev &
BACKEND_PID=$!

# Start Frontend
echo "🌐 Starting Frontend (http://localhost:5173)..."
cd /home/jim/Dev/NGOL-D/App && npm run dev &
FRONTEND_PID=$!

# Cleanup on exit
trap "kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; echo -e '\n✅ Stopped servers.'; exit" SIGINT SIGTERM

echo "✅ Servers running. Press Ctrl+C to stop."
wait
