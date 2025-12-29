{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  packages = [ 
    pkgs.nodejs_20 
    pkgs.mariadb_106   # ← includes BOTH mysql (client) AND mariadbd (server)
    pkgs.curl
  ];
  shellHook = ''
    echo "✅ Pure Nix Dev Shell (no sudo, no root)"
    echo "   mariadbd: $(command -v mariadbd)"
    echo "   mysql:    $(command -v mysql)"
    echo "   Version:  $(mariadbd --version | head -1)"
  '';
}
