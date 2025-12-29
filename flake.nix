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
      packages.frontend = frontend.default;
      apps.Backend = {
        type = "app";
        program = "${backend}/bin/ngol-d-backend";
      };
      apps.frontend-prod = {
        type = "app";
        program = "${frontend.serve}/bin/serve-prod";
      };
      devShells.default = pkgs.mkShell {
        # Use mariadb_106 for BOTH client and server (single version)
        packages = [ pkgs.nodejs_20 pkgs.yarn pkgs.mariadb_106 pkgs.curl ];
        shellHook = ''
          export MARIADB_HOST="127.0.0.1"
          export MARIADB_PORT="3306"
          export MARIADB_USER="ngol"
          export MARIADB_PASSWORD="ngol"
          export MARIADB_DATABASE="NGOL_D"
        '';
      };
      devShells.frontend = frontend.devShell;
    });
}
