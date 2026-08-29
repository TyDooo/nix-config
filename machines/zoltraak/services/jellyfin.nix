# WARN:
#   The `intel-media-sdk` is deprecated and does not build on recent channels.
#   Use VAAPI instead of QSV for hardware transcoding.
{ config, ... }:
{

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  users.users.jellyfin.extraGroups = [ "media" ];

  services.caddy.virtualHosts."jellyfin.driessen.family".extraConfig = ''
    reverse_proxy http://localhost:8096 {
      header_up X-Real-IP {remote_host}
    }
  '';

  environment.persistence = {
    "/persist".directories = [
      {
        directory = config.services.jellyfin.dataDir;
        inherit (config.services.jellyfin) user group;
        mode = "0700";
      }
    ];
  };

  clan.core.state.jellyfin = {
    folders = [ config.services.jellyfin.dataDir ];
    preBackupScript = ''
      systemctl stop jellyfin.service
    '';
    postBackupScript = ''
      systemctl start jellyfin.service
    '';
  };
}
