{
  self,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./modules

    self.nixosModules.qmk
  ];

  boot = {
    initrd.systemd.enable = true;
    loader.systemd-boot.enable = true;
  };

  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
  };

  system.nuke = {
    root = true; # Remove the root directory on each boot
    home = lib.mkForce false; # Not supported on this machine
  };

  # Enable binfmt emulation.
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    openFirewall = true;
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
    caligula # Like Balena Etcher, but as a TUI and actually available on Nix
    rockbox-utility
    bruno
    codex
    rsgain # ReplayGain calculation (used by Picard)
    yt-dlp
  ];
}
