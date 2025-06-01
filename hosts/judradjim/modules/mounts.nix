{config, ...}: {
  fileSystems = let
    cifsShare = share: {
      device = "//tower/${share}";
      fsType = "cifs";
      options = [
        "uid=tygo"
        "gid=tygo"
        "file_mode=0770,dir_mode=0770"
        "credentials=${config.sops.secrets."smb-credentials".path}"
        # Stolen from the wiki: this line prevents hanging on network split
        "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s"
      ];
    };
  in {
    "/mnt/user/media" = cifsShare "media";
    "/mnt/user/sauce" = cifsShare "sauce";
    "/mnt/user/share" = cifsShare "share";
    "/mnt/user/music" = cifsShare "music";
  };

  sops.secrets."smb-credentials" = {};
}
