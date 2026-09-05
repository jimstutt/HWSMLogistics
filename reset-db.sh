#!/usr/bin/env bash
set -e

echo "🛑 Stopping any existing MariaDB processes..."
pkill -9 mariadbd 2>/dev/null || true
sleep 2

echo "🛡️ Starting MariaDB in safe mode (background)..."
nix shell nixpkgs#mariadb --command mariadbd --datadir=./data/mariadb --socket=/tmp/mariadb.sock --skip-grant-tables &
sleep 3

echo "🔑 Resetting root credentials and granting TCP access..."
nix shell nixpkgs#mariadb --command mariadb --socket=/tmp/mariadb.sock -u root -e "
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '';
CREATE USER IF NOT EXISTS 'root'@'127.0.0.1' IDENTIFIED BY '';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' WITH GRANT OPTION;
FLUSH PRIVILEGES;
"

echo "🛑 Stopping safe mode..."
pkill -9 mariadbd 2>/dev/null || true
sleep 2

echo "🚀 Starting MariaDB normally (background)..."
nix shell nixpkgs#mariadb --command mariadbd --datadir=./data/mariadb --socket=/tmp/mariadb.sock --port=3306 &
sleep 3

echo "✅ MariaDB is fully reset and running! You can now start your backend."
