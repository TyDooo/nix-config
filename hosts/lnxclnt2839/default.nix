{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../common/global
    ../common/users/tygdri

    ../common/optional/hyprland.nix
    ../common/optional/pipewire.nix
  ];

  tydooo = {
    desktop = {
      enable = true;
      hostname = "lnxclnt2839";
      gfxmodeEfi = "1920x1080";
    };
    nvidia.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
}
