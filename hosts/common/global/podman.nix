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

      # Prune images and containers periodically
      autoPrune = {
        enable = true;
        flags = ["--all"];
        dates = "weekly";
      };
    };
  };

  # Enable Nvidia support for containers if the Nvidia drivers are found
  # in the list of xserver.videoDrivers.
  hardware.nvidia-container-toolkit.enable =
    builtins.any (driver: driver == "nvidia") config.services.xserver.videoDrivers;

  environment.persistence = {
    "/persist".directories = ["/var/lib/containers"];
  };
}
