#!/usr/bin/env bash
# ~/Dev/NGOL-D/start-mariadb.sh
# Spec: NGOLTechSpec.md — "MariaDB", no Docker
set -euo pipefail

echo "🔧 Starting MariaDB (NGOLTechSpec.md § Technical Specification)"
DATA_DIR="${NGOL_DATA_DIR:-./data/mariadb}"
mkdir -p "$DATA_DIR"

# Clean stale processes
pkill -f mariadbd 2>/dev/null || true

# Initialize (MariaDB 10.6+)
nix develop --command mariadb-install-db \
  --datadir="$DATA_DIR" \
  --user="$(id -un)" >/dev/null 2>&1

# Start on port 3307 (avoids 3306 conflicts, no socket issues)
nix develop --command mariadbd \
  --datadir="$DATA_DIR" \
  --user="$(id -un)" \
  --bind-address=127.0.0.1 \
  --port=3307 \
  --skip-networking=0 \
  --skip-log-bin \
  --skip-slow-query-log \
  --general-log=0 \
  --log-error=/dev/stderr \
  --skip-grant-tables &
MARIADB_PID=$!

# Wait for ready
for i in {1..15}; do
  if nix develop --command mysqladmin ping -u root -h 127.0.0.1 -P 3307 --silent 2>/dev/null; then
    break
  fi
  sleep 1
done

# Setup DB/user (spec: NGOL_D)
nix develop --command mysql -u root -h 127.0.0.1 -P 3307 -e "
  CREATE DATABASE IF NOT EXISTS NGOL_D;
  CREATE USER IF NOT EXISTS 'ngol'@'%' IDENTIFIED BY 'ngol';
  GRANT ALL PRIVILEGES ON NGOL_D.* TO 'ngol'@'%';
  FLUSH PRIVILEGES;
"

# Apply schema (spec-compliant)
nix develop --command mysql -u ngol -pngol -h 127.0.0.1 -P 3307 NGOL_D < Backend/schema.sql

echo "✅ MariaDB ready on localhost:3307"
echo "   Test: nix develop --command mysql -u ngol -pngol -h 127.0.0.1 -P 3307 -e 'SELECT 1;'"
