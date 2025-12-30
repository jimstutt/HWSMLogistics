{
  description = "NGO Logistics Dashboard (Node.js + MariaDB + Vue)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      # Backend derivation (unchanged)
      backend = pkgs.callPackage ./Backend/default.nix { inherit pkgs; };

      # Frontend production build derivation
      ngol-d-frontend = pkgs.stdenv.mkDerivation rec {
        pname = "ngol-d-frontend";
        version = "0.1.0";
        src = ./App;  # Critical: points to your frontend directory
        
        buildInputs = [ 
          pkgs.nodejs_20
          pkgs.pnpm
          pkgs.git  # Needed for npm dependencies that use git URLs
        ];
        
        # Isolate npm cache to avoid permission issues
        HOME = "/tmp";
        
        buildPhase = ''
          # Install dependencies with frozen lockfile
          pnpm install --frozen-lockfile --ignore-scripts
          
          # Build production artifacts
          pnpm run build
        '';
        
        installPhase = ''
          mkdir -p $out
          cp -r dist/* $out/  # Vite outputs to dist/ by default
        '';
        
        # Essential for static assets
        dontFixup = true;
      };

      # Legacy frontend package (for compatibility)
      legacy-frontend = pkgs.symlinkJoin {
        name = "legacy-frontend";
        paths = [ ngol-d-frontend ];
      };

      # Production server for frontend (for testing only)
      frontend-prod-server = pkgs.stdenv.mkDerivation {
        pname = "ngol-d-frontend-server";
        version = "0.1.0";
        src = ngol-d-frontend;
        
        buildInputs = [ pkgs.nodejs_20 ];
        
        buildPhase = ''
          npm install -g serve@14
        '';
        
        installPhase = ''
          mkdir -p $out/bin
          cat > $out/bin/serve-prod <<EOF
          #!${pkgs.bash}/bin/bash
          exec ${pkgs.nodejs_20}/bin/serve -s ${ngol-d-frontend} -p 5000
          EOF
          chmod +x $out/bin/serve-prod
        '';
      };

    in {
      packages = {
        # Primary packages
        Backend = backend;
        ngol-d-frontend = ngol-d-frontend;  # Required by deploy script
        
        # Legacy compatibility
        App = legacy-frontend;
      };

      apps = {
        Backend = {
          type = "app";
          program = "${backend}/bin/ngol-d-backend";
        };
        
        frontend-prod = {
          type = "app";
          program = "${frontend-prod-server}/bin/serve-prod";
        };
      };

      devShells = {
        default = pkgs.mkShell {
          packages = [ 
            pkgs.nodejs_20 
            pkgs.mariadb_106 
            pkgs.curl 
            pkgs.pnpm
          ];
          
          shellHook = ''
            export MARIADB_HOST="127.0.0.1"
            export MARIADB_PORT="3306"
            export MARIADB_USER="ngol"
            export MARIADB_PASSWORD="ngol"
            export MARIADB_DATABASE="NGOL_D"
            echo "✅ NGO Logistics Dev Shell (Node.js 20 + MariaDB 10.6)"
            echo "Frontend: cd App && pnpm dev"
            echo "Backend: cd Backend && npm run dev"
          '';
        };
        
        frontend = pkgs.mkShell {
          packages = [ pkgs.nodejs_20 pkgs.pnpm ];
          shellHook = ''
            cd App
            echo "✅ Frontend Dev Shell"
            echo "Available commands:"
            echo "  pnpm dev   → Start dev server (port 5173)"
            echo "  pnpm build → Build production artifacts"
          '';
        };
      };
    });
}