{ pkgs, ... }: {
  imports = [
    ../../optional/impermanence.nix

    ./fonts.nix
    ./pipewire.nix
  ];

  boot = {
    # Quite boot
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [ "quiet" ];

    plymouth.enable = true;
  };

  programs.firefox.enable = true;

  networking.networkmanager.enable = true;

  services.power-profiles-daemon.enable = true;

  services.upower.enable = true;

  environment.systemPackages = with pkgs; [
    mpv
  ];
}
