# ~/Dev/NGOL-D/App/default.nix
# Minimal Vue 3 frontend (Nixpkgs 24.11 compatible)
{ pkgs ? import <nixpkgs> { }, stdenv, lib }:
let
  nodejs = pkgs.nodejs_20;
  src = ./.;
  
  # Build frontend derivation
  build = stdenv.mkDerivation {
    pname = "ngol-d-frontend";
    version = "0.1.0";
    
    src = src;
    
    nativeBuildInputs = [ nodejs pkgs.npm ];
    
    buildPhase = ''
      export HOME=$TMPDIR
      export NODE_OPTIONS=--openssl-legacy-provider
      
      # Install dependencies with network access enabled
      echo "📦 Installing npm dependencies..."
      npm install --no-fund --no-audit --ignore-scripts
      
      # Build production artifacts
      echo "🚀 Building production frontend..."
      npm run build
    '';
    
    installPhase = ''
      echo "💾 Installing build artifacts..."
      mkdir -p $out
      cp -r dist/* $out/
      echo "✅ Frontend build successful!"
      ls -la $out
    '';
    
    # Essential for static assets
    dontFixup = true;
    
    # Allow network access during build (required for npm install)
    # This is SAFE because we pin dependencies via package-lock.json
    __noChroot = true;
    impureEnv = true;
    
    meta = {
      description = "NGO Logistics Dashboard Vue 3 frontend";
      platforms = lib.platforms.unix;
    };
  };
in rec {
  # Primary output: nix build .#App
  default = build;
  
  # Development shell: nix develop .#frontend
  devShell = pkgs.mkShell {
    packages = [ nodejs pkgs.npm ];
    
    shellHook = ''
      export NODE_OPTIONS=--openssl-legacy-provider
      echo "✅ NGOL-D Frontend Dev Shell (npm)"
      echo "   Commands:"
      echo "     npm install   → Install dependencies"
      echo "     npm run dev   → Start dev server (port 5173)"
      echo "     npm run build → Build production artifacts"
    '';
  };
  
  # Production static file server
  serve = pkgs.writeShellScriptBin "serve-prod" ''
    cd ${default}
    echo "🚀 Serving NGOL-D frontend from ${default}"
    echo "   Access at: http://localhost:8080"
    exec ${pkgs.python3}/bin/python -m http.server 8080
  '';
}
