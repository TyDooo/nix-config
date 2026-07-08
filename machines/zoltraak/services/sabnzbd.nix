{ config, lib, ... }:
let
  inherit (lib) singleton;

  port = 8080;
in
{

  services.sabnzbd = {
    enable = true;
    group = "media";
    configFile = null;
    allowConfigWrite = true;
  };

  users.users.sabnzbd.extraGroups = [ "media" ];

  # Tunnel all traffic through Proton VPN
  systemd.services.sabnzbd = {
    # vpnConfinement sets `bindsTo` and `after` automatically
    vpnConfinement = {
      enable = true;
      vpnNamespace = "proton0";
    };
    serviceConfig.UMask = "0002";
    # This shit doesn't work and I'm done with it -> disable
    preStart = lib.mkForce "";
  };

  systemd.tmpfiles.rules = [
    "d /mnt/user/downloads/usenet                   0770 sabnzbd media - -"
    "d /mnt/user/downloads/usenet/complete          2770 sabnzbd media - -"
    "d /mnt/user/downloads/usenet/complete/movies   2770 sabnzbd media - -"
    "d /mnt/user/downloads/usenet/complete/shows    2770 sabnzbd media - -"
    "d /mnt/user/downloads/usenet/complete/music    2770 sabnzbd media - -"
    "d /mnt/user/downloads/usenet/complete/anime    2770 sabnzbd media - -"
    "d /mnt/user/downloads/usenet/complete/prowlarr 2770 sabnzbd media - -"
    "d /mnt/user/downloads/usenet/incomplete        2750 sabnzbd media - -"
  ];

  environment.persistence = {
    "/persist".directories = [
      {
        directory = "/var/lib/sabnzbd";
        inherit (config.services.sabnzbd) user group;
        mode = "0750";
      }
    ];
  };

  clan.core.state.sabnzbd = {
    folders = [ "/var/lib/sabnzbd" ];
    preBackupScript = ''
      systemctl stop sabnzbd.service
    '';
    postBackupScript = ''
      systemctl start sabnzbd.service
    '';
  };

  vpnNamespaces.proton0.portMappings = singleton {
    from = port;
    to = port;
  };

  networking.firewall.allowedTCPPorts = [ port ];
}
