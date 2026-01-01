#!/usr/bin/env bash
# ~/Dev/NGOL-D/scripts/start-backend.sh
nix develop --command bash -c "
  export MARIADB_SOCKET=\"\$(realpath ./data/mariadb/run/mysqld.sock)\"
  cd Backend
  node server.js
"
