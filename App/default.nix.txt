# ~/Dev/NGOL-D/App/default.nix
# Minimal Vue 3 frontend (Nixpkgs 24.11 compatible)
{ pkgs ? import <nixpkgs> { }, stdenv, lib }:

let
  # Use npmlock2nix (modern alternative to yarn2nix)
  nodejs = pkgs.nodejs_20;
  src = ./.;
  packageLock = ./package-lock.json;
  # Build frontend
  build = stdenv.mkDerivation {
    pname = "ngol-d-frontend";
    version = "0.1.0";
    src = src;
    nativeBuildInputs = [ nodejs ];
    buildPhase = ''
      export HOME=$TMPDIR
      export NODE_OPTIONS=--openssl-legacy-provider
      npm ci --no-fund --no-audit
      npm run build
    '';
    installPhase = ''
      mkdir -p $out
      cp -r dist/* $out/
    '';
  };
in rec {
  # nix build .#App
  default = build;

  # Dev shell
  devShell = pkgs.mkShell {
    packages = [ nodejs ];
    shellHook = ''
      export NODE_OPTIONS=--openssl-legacy-provider
      echo "✅ NGOL-D Frontend Dev Shell"
      echo "   Run: npm run dev"
    '';
  };

  # Production server
  serve = pkgs.writeShellScriptBin "serve-prod" ''
    cd ${default}
    exec ${pkgs.python3}/bin/python -m http.server 8080
  '';
}
