{
  flake.nixosModules.nuke =
    { config, lib, ... }:
    let
      inherit (lib) optionalString mkIf mkOption;

      root = config.fileSystems."/";

      toSystemdDevice =
        device:
        lib.concatStringsSep "-" (
          lib.tail (map (lib.replaceString "-" "\\x2d") (lib.splitString "/" device))
        )
        + ".device";

      cfg = config.system.nuke;
    in
    {
      options.system.nuke = {
        root = mkOption {
          default = false;
          description = "Nuke root directory";
        };

        home = mkOption {
          default = false;
          description = "Nuke home directory";
        };
      };

      config = mkIf cfg.root {
        boot.initrd.systemd.services.rollback = lib.mkIf config.boot.initrd.systemd.enable {
          description = "Rollback BTRFS root subvolume to a pristine state";
          wantedBy = [ "initrd.target" ];
          # make sure it's done after the root device is present
          after = [ (toSystemdDevice root.device) ];
          requires = [ (toSystemdDevice root.device) ];
          # mount the root fs before clearing
          before = [ "sysroot.mount" ];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = ''
            mkdir -p /mnt

            # We first mount the btrfs root to /mnt
            # so we can manipulate btrfs subvolumes.
            mount -o subvol=/ ${root.device} /mnt

            btrfs subvolume delete -R /mnt/root

            echo "restoring blank /root subvolume..."
            btrfs subvolume snapshot /mnt/root-blank /mnt/root

            ${optionalString cfg.home ''
              echo "restoring blank /home subvolume..."
              btrfs subvolume delete -R /mnt/home
              btrfs subvolume snapshot /mnt/home-blank /mnt/home
            ''}

            # Once we're done rolling back to a blank snapshot,
            # we can unmount /mnt and continue on the boot process.
            umount /mnt
          '';
        };

        fileSystems."/persist".neededForBoot = true;
      };
    };
}
