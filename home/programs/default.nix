{ pkgs, ... }:

{
  imports = [
    ./firefox.nix
    ./vscode.nix
    ./kitty.nix
    ./discord.nix
    ./spicetify.nix
    ./games
    # ./xdg.nix
  ];

  home.packages = with pkgs; [
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
