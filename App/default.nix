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
    
    # FIX: Remove pkgs.npm reference - nodejs already includes npm
    nativeBuildInputs = [ nodejs ];
    
    buildPhase = ''
      export HOME=$TMPDIR
      export NODE_OPTIONS=--openssl-legacy-provider
      
      # Add verbose flag for better debugging
      echo "📦 Installing dependencies with npm..."
      npm ci --no-fund --no-audit --verbose
      
      echo "🚀 Building production artifacts..."
      npm run build
    '';
    
    installPhase = ''
      mkdir -p $out
      cp -r dist/* $out/
      echo "✅ Build successful! Files installed to $out"
    '';
    
    # Essential for static assets
    dontFixup = true;
    
    # Allow network access during build (required for npm)
    __noChroot = true;
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
    echo "🚀 Serving NGOL-D frontend from ${default}"
    echo "   Access at: http://localhost:8080"
    exec ${pkgs.python3}/bin/python -m http.server 8080
  '';
}
