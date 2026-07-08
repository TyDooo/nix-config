{ pkgs, lib, ... }:
let
  inherit (lib) getExe;
in
{
  systemd.services.prowlarr = {
    description = "Prowlarr";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    environment.HOME = "/var/empty";

    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${getExe pkgs.prowlarr} -nobrowser -data=/var/lib/private/prowlarr";
      Restart = "on-failure";
      StateDirectory = "prowlarr";
      StateDirectoryMode = "750";
      MemoryDenyWriteExecute = false;
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
      ];
    };
  };

  environment.persistence = {
    "/persist".directories = [
      {
        directory = "/var/lib/private/prowlarr";
        user = "nobody";
        group = "nogroup";
        mode = "0750";
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [ 9696 ];
}
