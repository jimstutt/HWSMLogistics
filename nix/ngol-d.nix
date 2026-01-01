# ~/Dev/NGOL-D/nix/ngol-d.nix
# Spec: NGOLTechSpec.md — NixOS implementation
{ config, pkgs, lib, ... }:

let
  backend = (import ../. {}).packages.${pkgs.system}.Backend;
in {
  # MariaDB (spec: "MariaDB with proper indexing, transactions")
  services.mysql = {
    enable = true;
    package = pkgs.mariadb_106;
    ensureDatabases = [ "NGOL_D" ];
    ensureUsers = [{
      name = "ngol";
      ensurePermissions = { "NGOL_D.*" = "ALL PRIVILEGES"; };
      password = "ngol";
    }];
  };

  # Backend service
  systemd.services.ngol-d-backend = {
    description = "NGOL-D Backend";
    after = [ "mysql.service" ];
    wantedBy = [ "multi-user.target" ];
    script = "${backend}/bin/ngol-d-backend";
    serviceConfig = {
      User = "ngol-d";
      Restart = "always";
      Environment = [
        "MARIADB_HOST=localhost"
        "MARIADB_PORT=3306"
        "MARIADB_USER=ngol"
        "MARIADB_PASSWORD=ngol"
        "MARIADB_DATABASE=NGOL_D"
      ];
    };
  };

  users.users.ngol-d = { isSystemUser = true; };
}
