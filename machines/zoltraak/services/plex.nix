{ config, ... }:
{
  services.plex = {
    enable = true;
    openFirewall = true;
  };

  users.users.plex.extraGroups = [ "media" ];

  services.caddy.virtualHosts."plex.driessen.family".extraConfig = ''
    reverse_proxy http://localhost:32400 {
      header_up X-Real-IP {remote_host}
    }
  '';

  environment.persistence = {
    "/persist".directories = [
      {
        directory = config.services.plex.dataDir;
        inherit (config.services.plex) user group;
        mode = "0700";
      }
    ];
  };

  clan.core.state.plex = {
    folders = [ config.services.plex.dataDir ];
    preBackupScript = ''
      systemctl stop plex.service
    '';
    postBackupScript = ''
      systemctl start plex.service
    '';
  };
}
