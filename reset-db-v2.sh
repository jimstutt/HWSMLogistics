#!/usr/bin/env bash
set -e

echo "🛑 Stopping any existing MariaDB processes..."
pkill -9 mariadbd 2>/dev/null || true
sleep 2

echo "🛡️ Starting MariaDB in safe mode (background)..."
nix shell nixpkgs#mariadb --command mariadbd --datadir=./data/mariadb --socket=/tmp/mariadb.sock --skip-grant-tables --skip-networking &
sleep 3

echo "🔑 Resetting root credentials via SQL file..."
# Write the SQL to a temporary file to avoid all shell quoting issues
cat << 'EOF' > /tmp/reset_root.sql
FLUSH PRIVILEGES;
DROP USER IF EXISTS 'root'@'localhost';
DROP USER IF EXISTS 'root'@'127.0.0.1';
CREATE USER 'root'@'localhost' IDENTIFIED BY '';
CREATE USER 'root'@'127.0.0.1' IDENTIFIED BY '';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

# Execute the SQL file
nix shell nixpkgs#mariadb --command mariadb --socket=/tmp/mariadb.sock -u root < /tmp/reset_root.sql
rm -f /tmp/reset_root.sql

echo "🛑 Stopping safe mode..."
pkill -9 mariadbd 2>/dev/null || true
sleep 2

echo "🚀 Starting MariaDB normally (background)..."
nix shell nixpkgs#mariadb --command mariadbd --datadir=./data/mariadb --socket=/tmp/mariadb.sock --port=3306 &
sleep 3

echo "✅ MariaDB is fully reset and running! You can now start your backend."
