# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  outputs,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    ./misc
    ./programs
    ./services
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];

    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "tygo";
    homeDirectory = "/home/tygo";
  };

  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  home.packages = with pkgs; [
    obsidian
    spotify
    easyeffects
    pavucontrol
    superfile
    dua
    brightnessctl
    streamrip
    telegram-desktop
    picard
    r2modman

    # plasma meuk
    kdePackages.dolphin
    kdePackages.dolphin-plugins
    kdePackages.ark
    kdePackages.kio
    kdePackages.kio-extras
    kdePackages.kimageformats
    kdePackages.kdegraphics-thumbnailers

    # Libraries and programs to ensure
    # that QT applications load without issues, e.g. missing libs.
    libsForQt5.qt5.qtwayland # qt5
    kdePackages.qtwayland # qt6
    qt6.qtwayland
    kdePackages.qqc2-desktop-style

    # qt5ct/qt6ct for configuring QT apps imperatively
    libsForQt5.qt5ct
    kdePackages.qt6ct

    # Some KDE applications such as Dolphin try to fall back to Breeze
    # theme icons. Lets make sure they're also found.
    libsForQt5.breeze-qt5
    kdePackages.breeze-icons
    qt6.qtsvg # needed to load breeze icons

    # Okular needs ghostscript to import PostScript files as PDFs
    # so we add ghostscript_headless as a dependency
    (symlinkJoin {
      name = "Okular";
      paths = with pkgs; [
        kdePackages.okular
        ghostscript_headless
      ];
    })
  ];

  programs.home-manager.enable = true;
  news.display = "silent";

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
