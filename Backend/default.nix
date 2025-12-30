{ pkgs, stdenv, lib }:
stdenv.mkDerivation {
  name = "ngol-d-backend";
  src = ../.;  # ← source is project root
  buildInputs = [ pkgs.nodejs_22 ];
  installPhase = ''
    mkdir -p $out/bin $out/lib
    
    # Find Backend files robustly
    BACKEND_DIR=$(find . -name server.js -path '*/Backend/*' -printf '%h\n' -quit)
    test -n "$BACKEND_DIR" || { echo "❌ Backend dir not found"; exit 1; }
    
    cp -v "$BACKEND_DIR"/server.js "$BACKEND_DIR"/mariadb.js "$BACKEND_DIR"/schema.sql $out/lib/
    cp -v "$BACKEND_DIR"/package.json $out/lib/
    cp -vr "$BACKEND_DIR"/models "$BACKEND_DIR"/routes "$BACKEND_DIR"/sockets $out/lib/
    
    cat > $out/bin/ngol-d-backend <<'SCRIPT'
#!/usr/bin/env bash
cd "$out/lib"
exec ${pkgs.nodejs_22}/bin/node server.js "$@"
SCRIPT
    chmod +x $out/bin/ngol-d-backend
  '';
}
