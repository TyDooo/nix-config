{pkgs, ...}: {
  imports = [
    ./firefox.nix
    ./vscode.nix
    ./kitty.nix
    ./discord.nix
    ./spicetify.nix
    ./games
    # ./xdg.nix
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0" # FIXME: Necessary for Obsidian, remove after new major update
  ];

  home.packages = with pkgs; [
    catppuccin-cursors.mochaDark
    r2modman
    vlc
    mpv

    # Utils
    pamixer

    obsidian # Note taking
    libsForQt5.okular # PDF viewer
    libsForQt5.gwenview # Image viewer

    # Screenshot
    grim
    slurp

    # Remote desktop client
    remmina
    freerdp
  ];
}
