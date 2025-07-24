{config, ...}: {
  services.newt = {
    enable = true;
    id = "pjokgu79hz92so8";
    endpoint = "https://pangolin.driessen.family";
    environmentFile = config.sops.secrets."newt/secret".path;
  };

  sops.secrets."newt/secret" = {};
}
