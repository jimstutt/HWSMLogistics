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
        frontendPkg = haskellPkgs.callCabal2nix "frontend" ./frontend {};
        
        startServersApp = pkgs.writeShellScriptBin "start-servers" ''
          export PATH=${pkgs.lib.makeBinPath [ pkgs.mariadb pkgs.python3 pkgs.cabal-install pkgs.wasmtime pkgs.gawk ]}:$PATH
          exec ${./scripts/start-servers.sh} "$@"
        '';

        checkApp = pkgs.writeShellScriptBin "run-checks" ''
          export PATH=${pkgs.lib.makeBinPath [ pkgs.cabal-install ]}:$PATH
          exec ${./scripts/run-checks.sh} "$@"
        '';
      in {
        packages = {
          inherit commonPkg backendPkg frontendPkg;
          app = frontendPkg; 
          backend = backendPkg;
          default = backendPkg;
        };
        
        apps = {
          start-servers = {
            type = "app";
            program = "${startServersApp}/bin/start-servers";
          };
          check = {
            type = "app";
            program = "${checkApp}/bin/run-checks";
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
            pkgs.openssl
            pkgs.wasmtime
            pkgs.python3
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
