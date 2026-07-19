{ config, ... }:
{
  systemd.network.enable = true;
  systemd.network = {
    netdevs = {
      "10-bond0" = {
        netdevConfig = {
          Kind = "bond";
          Name = "bond0";
        };
        bondConfig = {
          Mode = "802.3ad";
          TransmitHashPolicy = "layer3+4";
        };
      };
    };
    networks = {
      "30-enp2s0" = {
        matchConfig.Name = "enp2s0";
        networkConfig.Bond = "bond0";
        linkConfig.RequiredForOnline = "no";
      };
      "30-eno1" = {
        matchConfig.Name = "eno1";
        networkConfig.Bond = "bond0";
        linkConfig.RequiredForOnline = "no";
      };
      "40-bond0" = {
        matchConfig.Name = "bond0";
        linkConfig.RequiredForOnline = "routable";
        networkConfig.DHCP = "yes";

        address = [
          "fdfa:eded:1c37:50::50/64"
        ];
      };
    };
  };

  vpnNamespaces.proton0 = {
    enable = true;
    wireguardConfigFile = config.clan.core.vars.generators."vpn-proton0".files."configFile".path;
    accessibleFrom = [
      "127.0.0.1"
      "10.10.0.0/16"
    ];
    forward = {
      enable = true;
      qbittorrent = {
        enable = true;
        port = 8182;
      };
    };
  };

  clan.core.vars.generators."vpn-proton0" = {
    prompts."configFile".persist = true;
    prompts."configFile".type = "multiline";
  };
}
