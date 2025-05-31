{
  disko.devices = {
    disk.nvme0 = {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_500GB_S4EVNF0M618709Y"; # <-- edit
      type = "disk";

      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };

          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = ["-f"];
              mountOptions = [
                "compress=zstd"
                "ssd"
                "noatime"
                "discard=async"
              ];
              subvolumes = {
                "@root" = {mountpoint = "/";};
                "@nix" = {mountpoint = "/nix";};
                "@log" = {mountpoint = "/var/log";};
                "@persist" = {mountpoint = "/persist";};
              };
            };
          };

          swap = {
            size = "8G";
            content.type = "swap";
          };
        };
      };
    };

    disk.nvme1 = {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_1TB_S467NX0M718634R"; # <-- edit
      type = "disk";

      content = {
        type = "gpt";
        partitions.data = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = ["-f"];
            mountOptions = [
              "compress=zstd"
              "ssd"
              "noatime"
              "discard=async"
            ];
            subvolumes = {
              "@home" = {mountpoint = "/home";};
              "@games" = {mountpoint = "/mnt/games";};
            };
          };
        };
      };
    };

    disk.sata0 = {
      device = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_500GB_S3R3NF1JA65632X"; # <-- edit
      type = "disk";

      content = {
        type = "gpt";
        partitions.data = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = ["-f"];
            mountOptions = [
              "compress=zstd"
              "ssd"
              "noatime"
              "discard=async"
            ];
            subvolumes = {
              "@backup" = {mountpoint = "/mnt/backup";};
            };
          };
        };
      };
    };
  };

  swapDevices = [
    {device = "/dev/disk/by-partlabel/swap";}
  ];

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
}
