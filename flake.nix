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
        packages = [
          pkgs.nodejs_20
          pkgs.yarn
          pkgs.mariadb_106  # ← explicit 10.6 server + client
          pkgs.curl
        ];
        shellHook = ''
          echo "✅ NGO Logistics Dev Shell (MariaDB 10.6.21)"
          echo "   Use: ./scripts/run-full-stack-safe.sh"
        '';
      };
      devShells.frontend = frontend.devShell;
    });
}
