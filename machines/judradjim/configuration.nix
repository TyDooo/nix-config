{ pkgs, lib, ... }:
{
  imports = [
    ./modules
  ];

  boot = {
    initrd.systemd.enable = true;
    loader.systemd-boot.enable = true;
  };

  system.nuke = {
    root = true; # Remove the root directory on each boot
    home = lib.mkForce false; # Not supported on this machine
  };

  environment.systemPackages = with pkgs; [
    streamrip
    vscodium
    feishin # Subsonic compatible music player
    whipper # Music CD ripper
    picard # Music tagger
    telegram-desktop
    vesktop
    spotify
    obsidian
    darktable
  ];
}
