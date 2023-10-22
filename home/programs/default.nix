{ config, pkgs, ... }:

{
  imports = [
    ./firefox.nix
    ./vscode.nix
    ./kitty.nix
    ./discord.nix
    ./spicetify.nix
    ./git.nix
    ./games
    # ./xdg.nix
  ];

  home.packages = with pkgs; [
    gnumake
    neofetch
    catppuccin-cursors.mochaDark

    # Utils
    ripgrep
    btop
    nixfmt # TODO: Use cachix
    pamixer
    tree

    # Productivity
    obsidian

    # Screenshot
    grim
    slurp
  ];

}
