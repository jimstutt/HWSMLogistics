#!/usr/bin/env bash
set -e

# 1. Setup and start MariaDB
mkdir -p data/mariadb
if [ ! -d "data/mariadb/mysql" ]; then
  echo "Initializing MariaDB..."
  mariadb-install-db --datadir=$PWD/data/mariadb --auth-root-authentication-method=normal >/dev/null 2>&1
fi

echo "Starting MariaDB..."
mariadbd --datadir=$PWD/data/mariadb --port=3306 --bind-address=127.0.0.1 --socket=$PWD/data/mariadb/mariadb.sock &
MDB_PID=$!

# Wait for MariaDB
for i in {1..15}; do
  if mariadb -u root --socket=$PWD/data/mariadb/mariadb.sock -e "SELECT 1" >/dev/null 2>&1; then break; fi
  sleep 1
done

# Create DB and User
mariadb -u root --socket=$PWD/data/mariadb/mariadb.sock -e "CREATE DATABASE IF NOT EXISTS HWSM;"
mariadb -u root --socket=$PWD/data/mariadb/mariadb.sock -e "CREATE USER IF NOT EXISTS 'admin'@'localhost' IDENTIFIED BY 'admin';"
mariadb -u root --socket=$PWD/data/mariadb/mariadb.sock -e "GRANT ALL PRIVILEGES ON HWSM.* TO 'admin'@'localhost'; FLUSH PRIVILEGES;"
mariadb -u root --socket=$PWD/data/mariadb/mariadb.sock < backend/sql/schema.sql

# 2. Start Backend
echo "Starting Backend on port 3000..."
export PORT=3000
cabal run backend &
BACKEND_PID=$!

# 3. Generate and Serve Frontend
echo "Generating Frontend..."
mkdir -p frontend-dist
WASM_FILE=$(find dist-newstyle -name "frontend.wasm" | head -n 1)
if [ -n "$WASM_FILE" ]; then
  wasmtime $WASM_FILE > frontend-dist/index.html
else
  # Fallback if WASM isn't built yet in CI
  echo "<html><body><h1>HWSM Frontend</h1></body></html>" > frontend-dist/index.html
fi

echo "Starting Frontend Server on port 5173..."
cd frontend-dist
python -m http.server 5173 &
FRONTEND_PID=$!

# Cleanup on exit
trap "kill $FRONTEND_PID $BACKEND_PID $MDB_PID 2>/dev/null" EXIT
echo "All servers started. Waiting..."
wait -n
