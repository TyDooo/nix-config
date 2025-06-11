{
  pkgs,
  inputs',
  ...
}: {
  imports = [
    ./common.nix
  ];

  home.packages = with pkgs; [
    telegram-desktop
    protonvpn-gui
    thunderbird
    handbrake
    streamrip
    obsidian
    plexamp
    spotify
    vesktop
    whipper
    logseq
    picard
    vscode
    vlc

    inputs'.quickshell.packages.default
  ];
}
