{ pkgs ? import <nixpkgs> { }, stdenv, lib }:

let
  src = ./.;
  build = stdenv.mkDerivation {
    pname = "ngol-d-frontend";
    version = "1.0.0";
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
