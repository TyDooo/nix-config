{pkgs, ...}: {
  imports = [
    ./common.nix
  ];

  home.packages = with pkgs; [
    telegram-desktop
    thunderbird
    obsidian
    plexamp
    spotify
    vesktop
    logseq
    picard
    vscode
    vlc
  ];
}
