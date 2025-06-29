{pkgs, ...}: {
  services = {
    xserver.enable = true;

    desktopManager.gnome.enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };

    # Prevent gnome-keyring's ssh agent from regisering as the default SSH agent, ensuring
    # that gpg-agent can be used for SSH authentication without conflict.
    gnome.gcr-ssh-agent.enable = false;
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
}
