{
  config,
  pkgs,
  lib,
  ...
}: let
  dataDir = "/var/lib/fossorial";
  network = "fossorial";
in {
  networking.firewall = {
    allowedTCPPorts = [80 443]; # Traefik
    allowedUDPPorts = [51820]; # Wireguard
  };

  # For now, I use containers to run Pangolin. In the future, I either want to
  # switch to native services, or set-up my own tunneled reverse proxy solution
  # using wireguard.

  ############
  # Pangolin
  ############

  virtualisation.oci-containers.containers."pangolin" = {
    image = "fosrl/pangolin:1.3.0";
    volumes = ["${dataDir}/config:/app/config"];
    extraOptions = ["--network=${network}"];
  };

  systemd.services."podman-pangolin" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = ["podman-network-fossorial.service"];
    requires = ["podman-network-fossorial.service"];
    partOf = ["podman-fossorial-root.target"];
    wantedBy = ["podman-fossorial-root.target"];
  };

  ############
  # Gerbil
  ############

  virtualisation.oci-containers.containers."gerbil" = {
    image = "fosrl/gerbil:1.0.0";
    capabilities = {
      NET_ADMIN = true;
      SYS_MODULE = true;
    };
    ports = [
      "51820:51820/udp"
      "443:443"
      "80:80"
    ];
    extraOptions = ["--network=${network}"];
    volumes = ["${dataDir}/config:/var/config"];
    cmd = [
      "--reachableAt=http://gerbil:3003"
      "--generateAndSaveKeyTo=/var/config/key"
      "--remoteConfig=http://pangolin:3001/api/v1/gerbil/get-config"
      "--reportBandwidthTo=http://pangolin:3001/api/v1/gerbil/receive-bandwidth"
    ];
  };

  systemd.services."podman-gerbil" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-fossorial.service"
      "podman-pangolin.service"
    ];
    requires = [
      "podman-network-fossorial.service"
      "podman-pangolin.service"
    ];
    partOf = ["podman-fossorial-root.target"];
    wantedBy = ["podman-fossorial-root.target"];
  };

  ############
  # Traefik
  ############

  virtualisation.oci-containers.containers."traefik" = {
    image = "traefik:v3.3.3";
    environmentFiles = [config.sops.templates."traefik.env".path];
    volumes = [
      "${dataDir}/config/traefik:/etc/traefik:ro"
      "${dataDir}/config/letsencrypt:/letsencrypt"
      "${dataDir}/config/traefik/logs:/var/log/traefik"
    ];
    extraOptions = ["--network=container:gerbil"];
    cmd = ["--configFile=/etc/traefik/traefik_config.yml"];
  };

  systemd.services."podman-traefik" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-pangolin.service"
      "podman-gerbil.service"
    ];
    requires = [
      "podman-pangolin.service"
      "podman-gerbil.service"
    ];
    partOf = ["podman-fossorial-root.target"];
    wantedBy = ["podman-fossorial-root.target"];
  };

  # Networks - create and destroy podman network
  systemd.services."podman-network-fossorial" = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${pkgs.podman}/bin/podman network rm -f ${network}";
    };
    script = ''
      podman network inspect ${network} || podman network create ${network}
    '';
    partOf = ["podman-fossorial-root.target"];
    wantedBy = ["podman-fossorial-root.target"];
  };

  # Root target - allows starting/stopping all connected services at once
  systemd.targets."podman-fossorial-root" = {
    unitConfig = {
      Description = "Root target for fossorial services.";
    };
    wantedBy = ["multi-user.target"];
  };

  # Secrets
  sops.secrets.cloudflare_api_key = {
    sopsFile = ../secrets.yaml; # TODO: check if needed
  };

  sops.templates."traefik.env".content = ''
    CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder.cloudflare_api_key}
  '';
}
