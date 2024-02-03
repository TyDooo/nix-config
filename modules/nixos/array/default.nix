{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.tydooo.array;
  dataDisks = builtins.listToAttrs (map (branch: {
      name = "/mnt/disks/${branch.name}";
      value = {
        inherit (branch) fsType;
        device = "/dev/disk/by-label/${branch.label}";
        options = ["rw" "user" "auto"];
      };
    })
    cfg.branches);
in {
  options.tydooo.array = {
    enable = mkEnableOption false;
    branches = mkOption {
      type = types.nonEmptyListOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Name of the branch";
          };

          fsType = mkOption {
            type = types.str;
            description = "Filesystem type of the branch";
          };

          label = mkOption {
            type = types.str;
            description = "Label of the branch";
          };
        };
      });
      description = "Branches used by mergerfs";
    };
    targetPath = mkOption {
      type = types.str;
      description = "Mount point for the array";
      default = "/mnt/array";
    };
    poolPath = mkOption {
      type = types.str;
      description = "Mount point for the storage pool";
      default = "/mnt/pool";
    };
    cache = {
      fsType = mkOption {
        type = types.str;
        description = "Filesystem type for the cache";
        default = "xfs";
      };
      device = mkOption {
        type = types.str;
        description = "Device for the cache";
        default = "";
      };
      size = mkOption {
        type = types.str;
        description = ''
          Size of the cache disk.
          Should least enough space for the entire cache
        '';
        default = "";
      };
      path = mkOption {
        type = types.str;
        description = "Mount point for the cache";
        default = "/mnt/cache";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      mergerfs
      mergerfs-tools
    ];

    fileSystems =
      dataDisks
      // {
        # Mount the branches (disks) at the pool
        "${cfg.poolPath}" = {
          fsType = "fuse.mergerfs";
          device = builtins.concatStringsSep ":" (builtins.attrNames dataDisks);
          options = [
            "allow_other"
            "cache.files=off"
            "dropcacheonclose=true"
            "category.create=mfs" # TODO: Check if this policy is good
            "minfreespace=${cfg.cache.size}" # TODO: needed?
            "moveonenospc=true"
            "fsname=mergerfs"
          ];
        };

        # Mount the cache used for tiered caching
        "${cfg.cache.path}" = {
          inherit (cfg.cache) fsType device;
          options = ["rw" "user" "auto"];
        };

        # Mount the array at the target location (cache + pool = array)
        "${cfg.targetPath}" = {
          fsType = "fuse.mergerfs";
          device = "${cfg.cache.path}:${cfg.poolPath}";
          options = [
            "cache.files=partial"
            "dropcacheonclose=true"
            "category.create=lfs" # This assumes that the cache has less space than the storage
            "moveonenospc=true"
            "minfreespace=4G"
          ];
        };
      };

    services.mover = {
      enable = true;
      target = cfg.poolPath;
      cache = cfg.cache.path;
    };

    # services.snapraid = {
    #   enable = true;
    #   exclude = ["/tmp/" "/lost+found/"];
    #   dataDisks = builtins.listToAttrs (map (branch: {
    #       name = branch.name;
    #       value = {
    #         fsType = branch.fsType;
    #         device = "/dev/disk/by-label/${branch.label}";
    #         options = ["rw" "user" "auto"];
    #       };
    #     })
    #     cfg.branches);
    # };
  };
}
