#!/usr/bin/env bash
# ~/Dev/NGOL-D/scripts/kill-all.sh
set -euo pipefail

echo "💥 Killing all NGOL-D processes..."
pkill -f "mariadbd\|node.*server.js\|vite\|npm.*dev" 2>/dev/null || true
lsof -ti:3000,3001,3002,3003,3004,3005,3006,3007,5173,3306 | xargs kill -9 2>/dev/null || true

# Clean stale sockets
rm -f ./data/mariadb/mysqld.sock ./data/mariadb/run/mysqld.sock 2>/dev/null || true
mkdir -p ./data/mariadb/run

echo "✅ All servers stopped, sockets freed"
