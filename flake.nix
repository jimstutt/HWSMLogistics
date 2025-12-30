{
  description = "NGO Logistics Dashboard (Node.js + MariaDB + Vue)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      
      # Backend derivation
      backend = pkgs.callPackage ./Backend/default.nix { inherit pkgs; };
      
      # Frontend derivation
      frontend = pkgs.callPackage ./App { inherit pkgs; };

    in {
      packages = {
        # Primary packages
        Backend = backend;
        App = frontend.default;
        
        # CRITICAL: Add this for your deployment script
        ngol-d-frontend = frontend.default;
      };

      apps = {
        Backend = {
          type = "app";
          program = "${backend}/bin/ngol-d-backend";
        };
        
        frontend-prod = {
          type = "app";
          program = "${frontend.serve}/bin/serve-prod";
        };
      };

      devShells = {
        default = pkgs.mkShell {
          packages = [ pkgs.nodejs_20 pkgs.mariadb_106 pkgs.curl ];
          shellHook = ''
            export MARIADB_HOST="127.0.0.1"
            export MARIADB_PORT="3306"
            export MARIADB_USER="ngol"
            export MARIADB_PASSWORD="ngol"
            export MARIADB_DATABASE="NGOL_D"
            echo "✅ NGO Logistics Dev Shell (MariaDB 10.6)"
          '';
        };
        
        frontend = frontend.devShell;
      };
    });
}
