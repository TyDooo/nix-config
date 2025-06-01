{pkgs, ...}: {
  services = {
    xserver.enable = true;

    desktopManager.gnome.enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };

  programs.dconf.enable = true;

  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
    ])
    ++ (with pkgs; [
      cheese # webcam tool
      gnome-music
      # gnome-terminal
      epiphany # web browser
      geary # email reader
      evince # document viewer
      gnome-characters
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      gnome-weather
      gnome-connections
      gnome-maps
      decibels
    ]);

  environment.systemPackages = with pkgs.gnomeExtensions; [
    blur-my-shell
    caffeine
    zen
  ];

  # Override gnome-keyring to disable its built-in SSH agent component using meson build flags.
  # This prevents gnome-keyring's agent from automatically registering as the default SSH agent,
  # ensuring that gpg-agent can be used for SSH authentication without conflict.
  nixpkgs.overlays = [
    (_final: prev: {
      gnome-keyring = prev.gnome-keyring.overrideAttrs (oldAttrs: {
        mesonFlags =
          (builtins.filter (flag: flag != "-Dssh-agent=true") oldAttrs.mesonFlags)
          ++ [
            "-Dssh-agent=false"
          ];
      });
    })
  ];
}
