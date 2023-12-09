# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/users/tygo

    ../common/optional/desktop.nix
    ../common/optional/hyprland.nix
    ../common/optional/pipewire.nix
  ];

  networking.hostName = "aerial";

  boot = {
    # Use the ZEN kernel
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;

    # Override grub gfxmodeEfi
    loader.grub.gfxmodeEfi = "3440x1440";
  };

  services = {
    xserver.videoDrivers = ["nvidia"];
    hardware.openrgb.enable = true;
  };

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      # TODO: check what these do
      nvidia-vaapi-driver
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true; # Disable if issues with sleep/suspend
    # open = true; # Has RTX2080 TI support

    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  fileSystems = {
    "/data" = {device = "/dev/disk/by-label/games";};
    "/mnt/amadeus/data" = {
      device = "//192.168.1.127/data";
      fsType = "cifs";
      options = let
        automount_opts =
          # this line prevents hanging on network split
          "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in [
        "${automount_opts},credentials=/etc/nixos/smb-secrets,uid=1000,gid=100"
      ];
    };
  };
}
