{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    podman-compose
    podman-desktop
  ];

  virtualisation = {
    # Registries to search for images on `podman pull`
    containers.registries.search = [
      "docker.io"
      "quay.io"
      "ghcr.io"
      "gcr.io"
    ];

    podman = {
      enable = true;

      dockerCompat = true;
      dockerSocket.enable = true;

      defaultNetwork.settings.dns_enabled = true;

      # Enable Nvidia support for Podman if the Nvidia drivers are found
      # in the list of xserver.videoDrivers.
      enableNvidia = builtins.any (driver: driver == "nvidia") config.services.xserver.videoDrivers;

      # Prune images and containers periodically
      autoPrune = {
        enable = true;
        flags = ["--all"];
        dates = "weekly";
      };
    };
  };

  environment.persistence = {
    "/persist".directories = ["/var/lib/containers"];
  };
}
