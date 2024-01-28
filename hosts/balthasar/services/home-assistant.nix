let
  upstream_scheme = "http";
  upstream_host = "100.64.0.5";
  upstream_port = 8123;
in {
  # Home Assistant is hosted on a separate machine, but we want to access it
  # through a subdomain of our main domain. We use nginx to proxy requests to
  # the Home Assistant machine over the tailscale network.
  services.nginx.virtualHosts = {
    "homeassistant.driessen.family" = {
      forceSSL = true;
      enableACME = true;
      http2 = true;
      locations = {
        "/" = {
          proxyPass = "${upstream_scheme}://${upstream_host}:${toString upstream_port}";
          recommendedProxySettings = true;
        };
        "~ ^/(api|local|media)/" = {
          proxyPass = "${upstream_scheme}://${upstream_host}:${toString upstream_port}";
          recommendedProxySettings = true;
          proxyWebsockets = true;
        };
      };
    };
  };
}
