{ config, lib, ... }:
let
  diskoCfg = config.features.disko;

  ssdOpts = lib.optionals diskoCfg.isSSD [
    "discard=async"
    "ssd"
  ];

  subvolOpts =
    subvol:
    [
      "subvol=${subvol}"
      "noatime"
      "compress=zstd"
    ]
    ++ ssdOpts;

  persistentSubvol = {
    mountOptions = subvolOpts "persistent";
    mountpoint = "/persistent";
  };

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
    "/tmp" = {
      mountOptions = subvolOpts "tmp";
      mountpoint = "/tmp";
    };
    "/nix" = {
      mountOptions = subvolOpts "nix";
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
          "/persistent" = persistentSubvol;
        })
      ];
    };
  };

  primaryDisk = {
    main = {
      device = diskoCfg.primaryDrive;
      type = "disk";
      content.type = "gpt";
      content.partitions = lib.mkMerge [
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
              "/persistent" = persistentSubvol;
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
    isSSD = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether drives are SSDs (enables discard=async and ssd mount options)";
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
    disko.devices.disk = lib.mkMerge [
      primaryDisk
      (lib.mkIf diskoCfg.dualDrive secondaryDisk)
    ];
  };
}
