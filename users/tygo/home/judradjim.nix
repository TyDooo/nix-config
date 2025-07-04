{pkgs, ...}: {
  imports = [
    ./common.nix
  ];

  home.packages = with pkgs; [
    telegram-desktop
    protonvpn-gui
    thunderbird
    handbrake
    obsidian
    plexamp
    spotify
    vesktop
    whipper
    logseq
    picard
    vscode
    vlc
  ];
}
