{
  lib,
  pkgs,
  ...
}: {
  # Enable networking
  networking.networkmanager.enable = true;

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      configurationLimit = 5;
      gfxmodeEfi = lib.mkDefault "1920x1080";
      theme = pkgs.fetchzip {
        # https://github.com/AdisonCavani/distro-grub-themes
        url = "https://github.com/AdisonCavani/distro-grub-themes/raw/master/themes/nixos.tar";
        hash = "sha256-KQAXNK6sWnUVwOvYzVfolYlEtzFobL2wmDvO8iESUYE=";
        stripRoot = false;
      };
    };
  };

  services = {
    xserver = {
      # Enable the X11 windowing system.
      enable = true;

      # Enable the GNOME Desktop Environment.
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;

      # Configure keymap in X11
      layout = "us";
      xkbVariant = "";
    };

    # Enable CUPS to print documents.
    printing.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      # xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
    wlr.enable = true;
  };

  # TODO: decide what to do with this
  environment.variables = {
    NIXOS_OZONE_WL = "1";
    DISABLE_QT5_COMPAT = "0";
    GDK_BACKEND = "wayland,x11";
    ANKI_WAYLAND = "1";
    DIRENV_LOG_FORMAT = "";
    WLR_DRM_NO_ATOMIC = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_STYLE_OVERRIDE = "kvantum";
    MOZ_ENABLE_WAYLAND = "1";
    WLR_BACKEND = "vulkan";
    WLR_RENDERER = "vulkan";
    WLR_NO_HARDWARE_CURSORS = "1";
    CLUTTER_BACKEND = "wayland";
    GBM_BACKEND = "nvidia-drm";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
