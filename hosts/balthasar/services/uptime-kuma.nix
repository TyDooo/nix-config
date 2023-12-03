let
  port = 4000;
in {
  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "0.0.0.0";
      PORT = "${toString port}";
    };
  };

  networking.firewall.allowedTCPPorts = [port];
}
