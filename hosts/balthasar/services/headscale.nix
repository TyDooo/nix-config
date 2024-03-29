{config, ...}: let
  derpPort = 3478;
  url = "tailscale.driessen.family";
in {
  imports = [../../common/global/tailscale.nix];

  services = {
    headscale = {
      enable = true;
      port = 8085;
      address = "127.0.0.1";
      settings = {
        server_url = "https://${url}";
        metrics_listen_addr = "127.0.0.1:8095";
        logtail.enabled = false;
        log.level = "warn";
        ip_prefixes = ["100.64.0.0/10" "fd7a:115c:a1e0::/48"];

        derp.server = {
          enable = true;
          region_id = 999;
          stun_listen_addr = "0.0.0.0:${toString derpPort}";
        };
      };
    };

    nginx.virtualHosts = {
      "${url}" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            proxyPass = "http://localhost:${toString config.services.headscale.port}";
            proxyWebsockets = true;
          };
          "/metrics" = {
            proxyPass = "http://${config.services.headscale.settings.metrics_listen_addr}/metrics";
          };
        };
      };
    };
  };

  # Derp server
  networking.firewall.allowedUDPPorts = [derpPort];

  environment.systemPackages = [config.services.headscale.package];
}
