{
  config,
  lib,
  ...
}:
let
  diskoCfg = config.features.disko;

  subvolOpts =
    subvol: isSSD:
    [
      "subvol=${subvol}"
      "noatime"
      "compress=${diskoCfg.compression}"
    ]
    ++ lib.optionals isSSD [
      "discard=async"
      "ssd"
    ];

  # --- Partitions

  bootPartition = {
    name = "boot";
    size = "1M";
    type = "EF02";
  };

  espPartition = {
    name = "ESP";
    size = "1G";
    type = "EF00";
    content = {
      type = "filesystem";
      format = "vfat";
      mountpoint = "/boot";
    };
  };

  swapPartition = {
    size = diskoCfg.swap.size;
    content = {
      type = "swap";
      resumeDevice = true;
    };
  };

  rootSubvolumes = {
    "/nix" = {
      mountOptions = subvolOpts "nix" diskoCfg.isSSD.primary;
      mountpoint = "/nix";
    };
  };

  rootPartition = {
    name = "root";
    size = "100%";
    content = {
      type = "btrfs";
      extraArgs = [ "-f" ];
      subvolumes = lib.mkMerge [
        rootSubvolumes
        (lib.mkIf (!diskoCfg.dualDrive) {
          "/persistent" = {
            mountOptions = subvolOpts "persistent" diskoCfg.isSSD.primary;
            mountpoint = "/persistent";
          };
        })
      ];
    };
  };

  primaryDisk = {
    main = {
      device = diskoCfg.primaryDrive;
      type = "disk";
      content = {
        type = "gpt";
        partitions = lib.mkMerge [
          {
            boot = bootPartition;
            esp = espPartition;
          }
          (lib.mkIf diskoCfg.swap.enable {
            swap = swapPartition;
          })
          {
            root = rootPartition;
          }
        ];
      };
    };
  };

  secondaryDisk = {
    secondary = {
      device = diskoCfg.secondaryDrive;
      type = "disk";
      content = {
        type = "gpt";
        partitions.data = {
          name = "data";
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            subvolumes = {
              "/persistent" = {
                mountOptions = subvolOpts "persistent" diskoCfg.isSSD.secondary;
                mountpoint = "/persistent";
              };
            };
          };
        };
      };
    };
  };
in
{
  options.features.disko = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable declarative disk layout (disko)";
    };
    isSSD = {
      primary = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether the primary drive is an SSD (enables discard=async and ssd mount options)";
      };
      secondary = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether the secondary drive is an SSD (enables discard=async and ssd mount options)";
      };
    };
    dualDrive = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Spread /nix and /persistent across separate drives";
    };
    primaryDrive = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Primary/fastest drive";
      example = "/dev/nvme0n1";
    };
    secondaryDrive = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Secondary drive for /persistent (dual-drive mode)";
      example = "/dev/nvme1n1";
    };
    compression = lib.mkOption {
      type = lib.types.str;
      default = "zstd:3";
      description = "Btrfs compression algorithm and level";
    };
    swap = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Optional swap partition";
      };
      size = lib.mkOption {
        type = lib.types.str;
        default = "16G";
        description = "Swap partition size";
      };
    };
  };

  config = lib.mkIf diskoCfg.enable {
    assertions = [
      {
        assertion = diskoCfg.primaryDrive != "";
        message = "features.disko.primaryDrive must be set when disko is enabled";
      }
      {
        assertion = !diskoCfg.dualDrive || diskoCfg.secondaryDrive != "";
        message = "features.disko.secondaryDrive must be set when dualDrive is enabled";
      }
    ];
    nix.settings.auto-optimise-store = true;
    disko.devices = {
      nodev."/" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=40%"
          "mode=755"
        ];
      };
      disk = lib.mkMerge [
        primaryDisk
        (lib.mkIf diskoCfg.dualDrive secondaryDisk)
      ];
    };

    fileSystems = {
      "/nix".neededForBoot = true;
      "/persistent".neededForBoot = true;
    };
  };
}
