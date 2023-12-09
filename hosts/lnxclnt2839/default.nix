{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../common/global
    ../common/users/tygdri

    ../common/optional/desktop.nix
    ../common/optional/hyprland.nix
    ../common/optional/pipewire.nix
  ];

  networking.hostName = "lnxclnt2839";

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
}
