{pkgs, ...}: let
  media_gid = 600;
in {
  users = {
    groups.media = {gid = media_gid;};
    users.tygo.extraGroups = ["media"];
  };

  # Create a media folder and set the group to media
  systemd.tmpfiles.rules = [
    "d /mnt/array/media 0770 - media - -"
  ];

  services = {
    qbittorrent = {
      enable = true;
      gid = media_gid;
      secretsFilePath = ../secrets.yaml;
    };

    prowlarr = {
      enable = true;
      openFirewall = true;
    };

    sonarr = {
      enable = true;
      openFirewall = true;
      package = pkgs.sonarr-v4;
      group = "media";
    };

    radarr = {
      enable = true;
      openFirewall = true;
      group = "media";
    };

    bazarr = {
      enable = true;
      openFirewall = true;
      group = "media";
    };

    sabnzbd = {
      enable = true;
      group = "media";
    };

    jellyseerr = {
      enable = true;
      openFirewall = true;
    };
  };
}
