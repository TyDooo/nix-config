{ inputs, pkgs, ... }:
{
  imports = [
    inputs.vpn-confinement.nixosModules.default

    ./modules
    ./services
  ];

  environment.systemPackages = with pkgs; [
    rsync
  ];

  clan.core.networking.targetHost = "10.10.50.50";

  boot = {
    initrd.systemd.enable = true;
    loader.systemd-boot.enable = true;
  };

  system.nuke = {
    root = true; # Remove the root directory on each boot
    home = false; # I'm not confident enough to nuke the home directory yet
  };

  programs.dconf.enable = true; # FIXME: needed?

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-ocl
      intel-media-driver
      intel-compute-runtime-legacy1
    ];
  };

  users = {
    users.tydooo.extraGroups = [ "backup" ];
    groups.backup = { };
  };

  # Disable DNSStubListener to free up port 53 for Blocky
  services.resolved.settings.Resolve.DNSStubListener = false;

  systemd.services.systemd-tmpfiles-setup = {
    after = [ "mnt-user.mount" ];
    requires = [ "mnt-user.mount" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/private    0700 root root   - -"
    "d /mnt/user/downloads 0775 root media  - -"

    "d /mnt/disks/tank/backup 2775 root backup - -"
    "d /mnt/disks/tank/backup/home_assistant 2775 root backup - -"
    "d /mnt/disks/tank/backup/proxmox        2775 root backup - -"

    "d /mnt/user/media 2770 root media - -"
  ];
}
