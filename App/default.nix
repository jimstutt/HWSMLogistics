# ~/Dev/NGOL-D/App/default.nix
# Spec: NGOLTechSpec.md — "Vue.js 3.5.21", "Vite 4.5.14"
{ pkgs ? import <nixpkgs> { }, stdenv, lib }:

let
  src = ./.;
  build = stdenv.mkDerivation {
    pname = "ngol-d-frontend";
    version = "0.1.0";
    src = src;
    nativeBuildInputs = [ pkgs.nodejs_20 ];
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
  # REQUIRED for flake.nix:packages.App = frontend.default
  default = build;

  devShell = pkgs.mkShell {
    packages = [ pkgs.nodejs_20 ];
    shellHook = ''
      export NODE_OPTIONS=--openssl-legacy-provider
    '';
  };

  serve = pkgs.writeShellScriptBin "serve-prod" ''
    cd ${default}
    exec ${pkgs.python3}/bin/python -m http.server 8080
  '';
}
