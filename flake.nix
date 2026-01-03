{
  description = "NGO Logistics Dashboard (Node.js + MariaDB + Vue)";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      backend = pkgs.callPackage ./Backend/default.nix { inherit pkgs; };
      frontend = pkgs.callPackage ./App { inherit pkgs; };
    in {
      packages.Backend = backend;
      packages.App = frontend.default;
      
      apps.Backend = {
        type = "app";
        program = "${backend}/bin/ngol-d-backend";
      };
      
      apps.frontend-prod = {
        type = "app";
        program = "${frontend.serve}/bin/serve-prod";
      };

      # ✅ Required for nix develop .#frontend
      devShells.frontend = frontend.devShell;

      # Default dev shell (full stack)
      devShells.default = pkgs.mkShell {
        packages = [ pkgs.nodejs_22 pkgs.mariadb pkgs.curl ];
        shellHook = ''
          export MARIADB_HOST="127.0.0.1"
          export MARIADB_PORT="3306"  # ← 3306, not 3307
          export MARIADB_USER="ngol"
          export MARIADB_PASSWORD="ngol"
          export MARIADB_DATABASE="NGOL_D"
          echo "✅ NGO Logistics Dev Shell (MariaDB 10.11)"
        '';
      };
    });
}
