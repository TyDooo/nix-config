{ config, ... }:
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;

    forceEncodingConfig = true;

    hardwareAcceleration = {
      enable = true;
      type = "vaapi";
      device = "/dev/dri/renderD128";
    };

    transcoding = {
      enableHardwareEncoding = true;
      enableToneMapping = true;

      hardwareDecodingCodecs = {
        h264 = true;
        hevc = true;
        mpeg2 = true;
        vc1 = true;
        vp8 = true;
        vp9 = true;
      };

      hardwareEncodingCodecs = {
        hevc = true;
      };
    };
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
