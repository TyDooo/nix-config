{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.tydooo.desktop;
in {
  options.tydooo.desktop = {
    enable = mkEnableOption "the default desktop configuration";

    hostname = mkOption {
      type = types.str;
      default = null;
      example = "deepblue";
      description = "hostname to identify the instance";
    };

    gfxmodeEfi = mkOption {
      type = types.str;
      default = "auto";
      example = "1024x768";
      description = "The gfxmode to pass to GRUB when loading a graphical boot interface under EFI.";
    };
  };

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
          user = "greeter";
        };
      };
    };

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
        inherit (cfg) gfxmodeEfi;
        theme = pkgs.fetchzip {
          # https://github.com/AdisonCavani/distro-grub-themes
          url = "https://github.com/AdisonCavani/distro-grub-themes/raw/master/themes/nixos.tar";
          hash = "sha256-KQAXNK6sWnUVwOvYzVfolYlEtzFobL2wmDvO8iESUYE=";
          stripRoot = false;
        };
      };
    };

    # Enable networkmanager
    networking.networkmanager.enable = true;

    # Define the hostname
    networking.hostName = cfg.hostname;

    services = {
      xserver = {
        # Enable the X11 windowing system.
        enable = true;

        # Configure keymap in X11
        layout = "us";
        xkbVariant = "";
      };

      # Enable CUPS to print documents.
      printing.enable = true;

      gnome.gnome-keyring.enable = true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
      wlr.enable = true;
    };

    # TODO: decide what to do with this
    environment.variables = {
      BROWSER = "firefox";
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
    };

    programs.thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
        thunar-media-tags-plugin
      ];
    };

    hardware.opengl.enable = true;
  };
}
