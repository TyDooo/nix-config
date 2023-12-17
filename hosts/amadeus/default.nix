{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/users/tygo
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "amadeus"; # Define your hostname.

  tydooo.services = {
    plex.enable = true;
  };

  environment.systemPackages = with pkgs; [
    mergerfs
    mergerfs-tools
  ];

  fileSystems = let
    storage_disks = {
      "/mnt/disks/disk0" = "storage0";
      "/mnt/disks/disk1" = "storage1";
      "/mnt/disks/disk2" = "storage2";
      "/mnt/disks/disk3" = "storage3";
    };
  in
    (
      builtins.mapAttrs
      (mount_path: label: {
        fsType = "xfs";
        device = "/dev/disk/by-label/${label}";
        options = ["rw" "user" "auto"];
      })
      storage_disks
    )
    // {
      "/mnt/cctv" = {
        fsType = "xfs";
        device = "/dev/disk/by-label/cctv";
        options = ["rw" "user" "auto"];
      };

      # Mount storage
      "/mnt/storage" = {
        fsType = "fuse.mergerfs";
        device = "/mnt/disks/disk0:/mnt/disks/disk1:/mnt/disks/disk2:/mnt/disks/disk3";
        options = ["cache.files=partial" "dropcacheonclose=true" "category.create=mfs"];
      };
    };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
