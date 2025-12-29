# ~/Dev/NGOL-D/App/default.nix
# Nix-managed Vue 3 frontend (no network, reproducible)
{ pkgs ? import <nixpkgs> { }, stdenv, lib }:

let
  # Use pkgs.yarn2nix for reproducible builds
  yarnLock = ./yarn.lock;
  nodePackages = pkgs.yarn2nix.mkYarnPackage {
    inherit yarnLock;
    src = ./.;
    # Build with offline cache
    buildPhase = ''
      export HOME=$TMPDIR
      export NODE_OPTIONS=--openssl-legacy-provider
      yarn --offline build
    '';
    installPhase = ''
      mkdir -p $out
      cp -r dist/* $out/
    '';
  };
in rec {
  # nix build .#App
  default = nodePackages;

  # Dev shell (offline-safe)
  devShell = pkgs.mkShell {
    packages = [ pkgs.nodejs_20 pkgs.yarn ];
    shellHook = ''
      export NODE_OPTIONS=--openssl-legacy-provider
      echo "✅ NGOL-D Frontend Dev Shell (offline-safe)"
      echo "   Run: yarn --offline dev"
    '';
  };

  # Production server
  serve = pkgs.writeShellScriptBin "serve-prod" ''
    cd ${default}
    exec ${pkgs.nodejs_20}/bin/http-server -p 8080 -c-1
  '';
}
