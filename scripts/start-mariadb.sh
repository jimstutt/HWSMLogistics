#!/usr/bin/env bash
# ~/Dev/NGOL-D/scripts/start-mariadb.sh
set -euo pipefail

DATA_DIR="$(pwd)/data/mariadb-1011"
rm -rf "$DATA_DIR"
mkdir -p "$DATA_DIR"

# Use pkgs.mariadb (10.11) — matches CI
nix shell nixpkgs#mariadb -c sh -c "
  # Initialize 10.11 data
  mariadb-install-db --datadir='$DATA_DIR' --user=\$(id -un) --skip-test-db >/dev/null

  # Start cleanly
  mariadbd \
    --no-defaults \
    --datadir='$DATA_DIR' \
    --user=\$(id -un) \
    --bind-address=127.0.0.1 \
    --port=3307 \
    --skip-networking=0 \
    --log-error='$DATA_DIR/error.log' &
  
  MARIADB_PID=\$!

  for i in \$(seq 1 20); do
    if mysqladmin ping -u root -h 127.0.0.1 -P 3307 --silent 2>/dev/null; then
      mysql -u root -h 127.0.0.1 -P 3307 -e \"CREATE DATABASE IF NOT EXISTS NGOL_D;\"
      mysql -u root -h 127.0.0.1 -P 3307 -e \"CREATE USER IF NOT EXISTS 'ngol'@'%' IDENTIFIED BY 'ngol';\"
      mysql -u root -h 127.0.0.1 -P 3307 -e \"GRANT ALL PRIVILEGES ON NGOL_D.* TO 'ngol'@'%';\"
      echo '✅ MariaDB 10.11 ready on port 3307'
      break
    fi
    sleep 1
  done

  wait \$MARIADB_PID 2>/dev/null || true
"
