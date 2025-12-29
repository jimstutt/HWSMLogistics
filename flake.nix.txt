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
      # nix build .#Backend
      packages.Backend = backend;
      # nix build .#App → matches your correction
      packages.App = frontend.default;
      # nix run .#Backend
      apps.Backend = {
        type = "app";
        program = "${backend}/bin/ngol-d-backend";
      };
      # nix run .#frontend-prod
      apps.frontend-prod = {
        type = "app";
        program = "${frontend.serve}/bin/serve-prod";
      };
      # nix develop → full stack dev
      devShells.default = pkgs.mkShell {
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
      devShells.frontend = frontend.devShell;
    });
}
