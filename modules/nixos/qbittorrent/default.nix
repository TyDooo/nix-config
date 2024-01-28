{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.services.qbittorrent;
in {
  options.services.qbittorrent = {
    enable = mkEnableOption (mdDoc "qbittorrent");

    port = mkOption {
      type = types.int;
      default = 8182;
      description = "Port to expose the qbittorrent webui on";
    };

    uid = mkOption {
      type = types.int;
      default = 1000;
      description = "UID of the user that should own the qbittorrent files";
    };

    gid = mkOption {
      type = types.int;
      default = 1000;
      description = "GID of the user that should own the qbittorrent files";
    };

    secretsFilePath = mkOption {
      type = types.path;
      default = ./secrets.yaml;
      description = "Path to the secrets file";
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /var/lib/qbittorrent 0770 - media - -"
      "d /tmp/gluetun 0777 - media - -"
    ];

    sops = {
      secrets = {
        protonvpn_wg_private_key = {
          sopsFile = cfg.secretsFilePath;
        };

        torrent-user = {
          sopsFile = cfg.secretsFilePath;
        };

        torrent-pass = {
          sopsFile = cfg.secretsFilePath;
        };
      };

      templates = {
        "gluetun.env".content = ''
          VPN_SERVICE_PROVIDER="custom"
          VPN_TYPE="wireguard"
          WIREGUARD_PUBLIC_KEY="3P4ocB2/quwPDO74RB/tUx8VSqeDWPfGs5NrhL/qnFc="
          WIREGUARD_PRIVATE_KEY="${config.sops.placeholder.protonvpn_wg_private_key}"
          WIREGUARD_ADDRESSES="10.2.0.2/32"
          VPN_ENDPOINT_IP="185.107.44.200"
          VPN_ENDPOINT_PORT="51820"
          VPN_DNS_ADDRESS="10.2.0.1"
          VPN_PORT_FORWARDING="on"
          VPN_PORT_FORWARDING_PROVIDER=protonvpn
          TZ="Europe/Amsterdam"
          UPDATER_PERIOD=24h
        '';

        "gluebit.env".content = ''
          QBITTORRENT_PASS = "${config.sops.placeholder.torrent-pass}";
          QBITTORRENT_PORT = "${toString cfg.port}";
          QBITTORRENT_SERVER = "127.0.0.1";
          QBITTORRENT_USER = "${config.sops.placeholder.torrent-user}";
          PORT_FORWARDED: /tmp/gluetun/forwarded_port
          HTTP_S: http
        '';
      };
    };

    virtualisation.oci-containers.containers = {
      gluetun = {
        image = "qmcgaw/gluetun";
        environmentFiles = [config.sops.templates."gluetun.env".path];
        ports = [
          "${toString cfg.port}:${toString cfg.port}" # qbittorrent webui
        ];
        volumes = [
          "/tmp/gluetun:/tmp/gluetun:rw"
        ];
        log-driver = "journald";
        extraOptions = [
          "--cap-add=NET_ADMIN"
          "--device=/dev/net/tun"
        ];
      };

      qbittorrent = {
        image = "ghcr.io/linuxserver/qbittorrent:4.6.2";
        environment = {
          PGID = toString cfg.gid;
          PUID = toString cfg.uid;
          TZ = "Europe/Amsterdam";
          WEBUI_PORT = "${toString cfg.port}";
        };
        volumes = [
          "/mnt/array/media/torrents:/downloads:rw"
          "/var/lib/qbittorrent:/config:rw"
        ];
        dependsOn = ["gluetun"];
        log-driver = "journald";
        extraOptions = ["--network=container:gluetun"];
      };

      gluetun-qbittorrent-port-manager = {
        image = "snoringdragon/gluetun-qbittorrent-port-manager";
        environmentFiles = [config.sops.templates."gluebit.env".path];
        volumes = ["/tmp/gluetun:/tmp/gluetun:ro"];
        log-driver = "journald";
        extraOptions = ["--network=container:gluetun"];
        dependsOn = ["gluetun" "qbittorrent"];
      };
    };
  };
}
