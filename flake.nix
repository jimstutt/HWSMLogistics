{
  description = "HWSMLogistics: Haskell Servant MariaDB Wasm App";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    ghc-wasm-meta.url = "gitlab:haskell-wasm/ghc-wasm-meta?host=gitlab.haskell.org";
  };
  outputs = { self, nixpkgs, flake-utils, ghc-wasm-meta }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; config = { allowBroken = true; }; };
        haskellPkgs = pkgs.haskellPackages;
        wasmToolchain = ghc-wasm-meta.packages.${system}.all_9_10;
        
        commonPkg = haskellPkgs.callCabal2nix "common" ./common {};
        backendPkg = haskellPkgs.callCabal2nix "backend" ./backend { common = commonPkg; };
        # Frontend built natively by Nix will just print the HTML to stdout
        frontendPkg = haskellPkgs.callCabal2nix "frontend" ./frontend {};
        
        # Script to start MariaDB, Backend, and Frontend for CI/CD
        startServersScript = pkgs.writeShellScriptBin "start-servers" ''
          set -e
          export PATH=${pkgs.lib.makeBinPath [ pkgs.mariadb pkgs.python3 pkgs.cabal-install pkgs.wasmtime pkgs.gawk ]}:$PATH
          
          # 1. Setup MariaDB
          mkdir -p data/mariadb
          if [ ! -d "data/mariadb/mysql" ]; then
            mariadb-install-db --datadir=$PWD/data/mariadb --auth-root-authentication-method=normal >/dev/null 2>&1
          fi
          
          mariadbd --datadir=$PWD/data/mariadb --port=3306 --bind-address=127.0.0.1 --socket=$PWD/data/mariadb/mariadb.sock &
          MDB_PID=$!
          
          # Wait for MariaDB to be ready
          for i in {1..15}; do
            if mariadb -u root --socket=$PWD/data/mariadb/mariadb.sock -e "SELECT 1" >/dev/null 2>&1; then break; fi
            sleep 1
          done
          
          # Create DB and User
          mariadb -u root --socket=$PWD/data/mariadb/mariadb.sock -e "CREATE DATABASE IF NOT EXISTS HWSM;"
          mariadb -u root --socket=$PWD/data/mariadb/mariadb.sock -e "CREATE USER IF NOT EXISTS 'admin'@'localhost' IDENTIFIED BY 'admin';"
          mariadb -u root --socket=$PWD/data/mariadb/mariadb.sock -e "GRANT ALL PRIVILEGES ON HWSM.* TO 'admin'@'localhost'; FLUSH PRIVILEGES;"
          mariadb -u root --socket=$PWD/data/mariadb/mariadb.sock < ${./backend/sql/schema.sql}
          
          # 2. Start Backend
          export PORT=3000
          ${backendPkg}/bin/backend &
          BACKEND_PID=$!
          
          # 3. Generate and Serve Frontend
          mkdir -p frontend-dist
          ${frontendPkg}/bin/frontend > frontend-dist/index.html
          
          cd frontend-dist
          python -m http.server 5173 &
          FRONTEND_PID=$!
          
          # Cleanup on exit
          trap "kill $FRONTEND_PID $BACKEND_PID $MDB_PID 2>/dev/null" EXIT
          wait -n
        '';
        
        # Script to run tests
        checkScript = pkgs.writeShellScriptBin "run-checks" ''
          set -e
          export PATH=${pkgs.lib.makeBinPath [ pkgs.cabal-install ]}:$PATH
          # Add actual cabal test commands here when tests are written
          echo "Running smoke checks..."
          cabal check
        '';
        
      in {
        packages = {
          inherit commonPkg backendPkg frontendPkg;
          backend = backendPkg;
          app = frontendPkg; # CI expects .#app
          default = backendPkg;
        };
        
        apps = {
          start-servers = {
            type = "app";
            program = "${startServersScript}/bin/start-servers";
          };
          check = {
            type = "app";
            program = "${checkScript}/bin/run-checks";
          };
        };
        
        devShells.default = pkgs.mkShell {
          buildInputs = [
            haskellPkgs.cabal-install
            haskellPkgs.haskell-language-server
            pkgs.mariadb
            pkgs.pkg-config
            pkgs.pcre
            pkgs.zlib
            pkgs.wasmtime
            pkgs.python3
            pkgs.nixpkgs-fmt
            wasmToolchain
          ];
          shellHook = ''
            echo "[HRSM] Dev shell loaded. Wasm Compiler: wasm32-wasi-ghc (GHC 9.10)"
            export MARIADB_HOST="127.0.0.1"
            export MARIADB_PORT="3306"
            export MARIADB_USER="admin"
            export MARIADB_PASSWORD="admin"
            export MARIADB_DATABASE="HWSM"
            export PORT="3000"
          '';
        };
      }
    );
}
