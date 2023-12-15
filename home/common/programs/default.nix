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
    vim
    gnumake
    neofetch
    catppuccin-cursors.mochaDark

    # Utils
    pamixer

    # Productivity
    obsidian

    # Screenshot
    grim
    slurp
  ];
}
