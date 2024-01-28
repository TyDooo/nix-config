{
  pkgs,
  config,
  ...
}: let
  arrayPath = "/mnt/array";
in {
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/users/tygo

    # ./services/frigate.nix
    ./services/navidrome.nix
    ./services/servarr.nix
    ./services/stash.nix
  ];

  environment.systemPackages = with pkgs; [rclone];

  # virtualisation.docker.enable = true;
  # users.users.tygo.extraGroups = ["docker"];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "amadeus";

  # Enable powertop auto tuning on startup
  powerManagement.powertop.enable = true;

  tydooo = {
    array = {
      enable = true;
      targetPath = arrayPath;
      branches = [
        # The order of the branches is important!
        {
          name = "disk0";
          label = "storage0";
          fsType = "xfs";
        }
        {
          name = "disk1";
          label = "storage1";
          fsType = "xfs";
        }
        {
          name = "disk2";
          label = "storage2";
          fsType = "xfs";
        }
        {
          name = "disk3";
          label = "storage3";
          fsType = "xfs";
        }
      ];
      cache = {
        fsType = "ext4";
        device = "/dev/disk/by-label/cache";
        size = "700G";
      };
    };

    services = {
      plex.enable = true;
    };
  };

  # TODO: Move this HDD to another machine
  fileSystems."/mnt/cctv" = {
    fsType = "xfs";
    device = "/dev/disk/by-label/cctv";
    options = ["rw" "user" "auto"];
  };

  # fileSystems = let
  #   storage_disks = {
  #     "/mnt/disks/disk0" = "storage0";
  #     "/mnt/disks/disk1" = "storage1";
  #     "/mnt/disks/disk2" = "storage2";
  #     "/mnt/disks/disk3" = "storage3";
  #   };
  # in
  #   (
  #     builtins.mapAttrs
  #     (mount_path: label: {
  #       fsType = "xfs";
  #       device = "/dev/disk/by-label/${label}";
  #       options = ["rw" "user" "auto"];
  #     })
  #     storage_disks
  #   )
  #   // {
  #     "/mnt/cctv" = {
  #       fsType = "xfs";
  #       device = "/dev/disk/by-label/cctv";
  #       options = ["rw" "user" "auto"];
  #     };

  #     # Mount storage
  #     "/mnt/storage" = {
  #       fsType = "fuse.mergerfs";
  #       device = builtins.concatStringsSep ":" (builtins.attrNames storage_disks);
  #       options = [
  #         "allow_other"
  #         "cache.files=off"
  #         "dropcacheonclose=true"
  #         "category.create=mfs" # TODO: Check if this policy is good
  #         "minfreespace=700G" # At least enough space for the entire cache
  #         "moveonenospc=true"
  #         "fsname=mergerfs"
  #       ];
  #     };

  #     "/mnt/disks/cache" = {
  #       fsType = "ext4";
  #       device = "/dev/disk/by-label/cache";
  #       options = ["rw" "user" "auto"];
  #     };

  #     "/mnt/cached" = {
  #       fsType = "fuse.mergerfs";
  #       device = "/mnt/disks/cache:/mnt/storage";
  #       options = [
  #         "cache.files=partial"
  #         "dropcacheonclose=true"
  #         "category.create=lfs" # This assumes that the cache has less space than the storage
  #         "moveonenospc=true"
  #         "minfreespace=4G"
  #       ];
  #     };
  #   };

  networking.firewall.allowPing = true;

  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    extraConfig = ''
      workgroup = WORKGROUP
      netbios name = ${config.networking.hostName}
      security = user
      guest account = nobody
      map to guest = bad user
    '';
    shares = {
      media = {
        path = "${arrayPath}/media";
        browseable = true;
        "read only" = false;
        "guest ok" = false;
        "create mask" = "0644";
        "directory mask" = "0755";
        "force group" = "media";
      };
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
