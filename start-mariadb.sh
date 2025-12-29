#!/usr/bin/env bash
# ~/Dev/NGOL-D/start-mariadb.sh
# Starts MariaDB using nixpkgs#mariadb_106 (server + client)
set -euo pipefail

DATA_DIR="${NGOL_MARIADB_DIR:-./data/mariadb}"
PORT="${NGOL_MARIADB_PORT:-3306}"
SOCKET="${DATA_DIR}/mysqld.sock"

echo "🔧 Starting MariaDB for NGOL-D..."
echo "   Data: $DATA_DIR"
echo "   Port: $PORT"
echo "   Socket: $SOCKET"

# Clean start
rm -rf "$DATA_DIR" && mkdir -p "$DATA_DIR"

# Initialize with MariaDB 10.6+ method
nix shell nixpkgs#mariadb_106 -c mariadb-install-db \
  --datadir="$DATA_DIR" \
  --user="$(id -un)" >/dev/null 2>&1

# Start server
nix shell nixpkgs#mariadb_106 -c mariadbd \
  --datadir="$DATA_DIR" \
  --user="$(id -un)" \
  --port="$PORT" \
  --socket="$SOCKET" \
  --skip-grant-tables \
  --skip-log-error &
MARIADB_PID=$!

# Wait for ready
for i in {1..10}; do
  if nix shell nixpkgs#mariadb_106 -c mysqladmin \
    ping -u root -S "$SOCKET" --silent 2>/dev/null; then
    break
  fi
  sleep 1
done

# Setup NGOL_D database/user
nix shell nixpkgs#mariadb_106 -c mysql -u root -S "$SOCKET" -e "
  CREATE DATABASE IF NOT EXISTS NGOL_D;
  CREATE USER IF NOT EXISTS 'ngol'@'localhost' IDENTIFIED BY 'ngol';
  GRANT ALL PRIVILEGES ON NGOL_D.* TO 'ngol'@'localhost';
  FLUSH PRIVILEGES;
"

# Apply schema
if [[ -f Backend/schema.sql ]]; then
  nix shell nixpkgs#mariadb_106 -c mysql -u ngol -pngol -S "$SOCKET" NGOL_D < Backend/schema.sql
fi

echo "✅ MariaDB ready on port $PORT"
echo "   Test: nix shell nixpkgs#mariadb_106 -c mysql -u ngol -pngol -S $SOCKET NGOL_D -e 'SELECT 1;'"
