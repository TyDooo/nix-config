{ grimoire-utils, config, ... }:
let
  downloadsPath = "/mnt/user/downloads/soulseek";
  musicPath = "/mnt/user/media/music";
in
{
  services.slskd = {
    enable = true;
    openFirewall = true;
    domain = null;
    environmentFile = config.clan.core.vars.generators."slskd".files."envfile".path;

    settings = {
      directories.downloads = downloadsPath;
      directories.incomplete = "${downloadsPath}/.incomplete";

      shares.directories = [
        "${musicPath}/digital_purchases"
        "${musicPath}/downloaded"
        "${musicPath}/physical_collection"
      ];
      shares.filters = [
        "\.ini$"
        "Thumbs.db$"
        "\.DS_Store$"
      ];
    };
  };

  systemd.tmpfiles.settings."10-slskd-downloads" = {
    "${downloadsPath}".d = {
      mode = "2775";
      inherit (config.services.slskd) user;
      group = "media";
    };

    "${downloadsPath}/.incomplete".d = {
      mode = "2775";
      inherit (config.services.slskd) user;
      group = "media";
    };
  };

  systemd.services.slskd.serviceConfig = {
    UMask = "0002";
    RequiresMountsFor = [
      config.services.slskd.settings.directories.downloads
      config.services.slskd.settings.directories.incomplete
    ]
    ++ config.services.slskd.settings.shares.directories;
  };

  users.users.slskd.extraGroups = [ "media" ];

  networking.firewall.allowedTCPPorts = [ config.services.slskd.settings.web.port ];

  clan.core.vars.generators."slskd" = grimoire-utils.mkEnvGenerator [
    "SLSKD_SLSK_USERNAME"
    "SLSKD_SLSK_PASSWORD"
    "SLSKD_USERNAME"
    "SLSKD_PASSWORD"
  ];

  environment.persistence = {
    "/persist".directories = [
      {
        directory = "/var/lib/slskd";
        inherit (config.services.slskd) user group;
      }
    ];
  };
}
