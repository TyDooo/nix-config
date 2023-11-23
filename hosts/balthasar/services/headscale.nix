{
  imports = [ ../../common/global/tailscale.nix ];

  services = {
    headscale = {
      enable = true;
      port = 8085;
      address = "127.0.0.1";
    };

    tailscale.useRoutingFeatures = "both";
  };
}
