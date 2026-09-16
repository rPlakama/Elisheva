{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    mkEnableOption
    mkMerge
    optionalAttrs
    optionals
    genAttrs
    ;
  inherit (lib.types)
    bool
    str
    ;

  cfg = config.features.disko;

  # Partition 1 of the secondary drive, e.g. /dev/nvme0n1 -> /dev/nvme0n1p1.
  secondaryPart =
    if builtins.match ".*[0-9]$" cfg.secondaryDrive != null then
      "${cfg.secondaryDrive}p1"
    else
      "${cfg.secondaryDrive}1";

  # Optional swap partition appended to the primary drive's GPT.
  swapPartition = optionalAttrs cfg.swap.enable {
    swap = {
      size = cfg.swap.size;
      content = {
        type = "swap";
        resumeDevice = true;
      };
    };
  };

  # Bootable primary drive; `rootContent` is whatever ends up mounted on `/`.
  primaryDisk = rootContent: {
    main = {
      device = cfg.primaryDrive;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
          esp = {
            name = "ESP";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            name = "root";
            label = "PrimaryDrive";
            size = "100%";
            content = rootContent;
          };
        }
        // swapPartition;
      };
    };
  };

  # Secondary drive, either an unformatted partition joined into the btrfs pool
  # (`content = null`) or an independent XFS filesystem.
  # Named "0-secondary" so it sorts before "main": disko processes disks in
  # alphabetical order and mkfs.btrfs needs this partition to already exist.
  secondaryDisk = content: {
    "0-secondary" = {
      device = cfg.secondaryDrive;
      type = "disk";
      content = {
        type = "gpt";
        partitions.data = {
          name = "data";
          label = "SecondaryDrive";
          size = "100%";
          inherit content;
        };
      };
    };
  };

  btrfsMountOptions = [
    "noatime"
    "compress=${cfg.btrfs.compression}"
    "ssd"
    "discard=async"
  ];

  # One btrfs pool spans both drives: data single (files land on one device, so
  # a drive failure only costs its own files) + metadata raid1.
  btrfsRoot = {
    type = "btrfs";
    extraArgs = [
      "-f"
    ]
    ++ optionals cfg.dualDrive [
      "-d"
      "single"
      "-m"
      "raid1"
      secondaryPart
    ];
    subvolumes = genAttrs [ "/nix" "/persistent" ] (mountpoint: {
      inherit mountpoint;
      mountOptions = btrfsMountOptions;
    });
  };

  # XFS does not support subvolumes, so it cannot back an ephemeral (tmpfs) root.
  # noatime avoids atime metadata writes; logbsize batches metadata into larger
  # log buffers, trimming small random writes (helps DRAM-less NVMe a little).
  xfsRoot = {
    type = "filesystem";
    format = "xfs";
    mountpoint = "/";
    mountOptions = [
      "noatime"
      "logbsize=256k"
    ];
  };

  xfsSecondaryData = {
    type = "filesystem";
    format = "xfs";
    mountpoint = cfg.xfs.secondaryMount;
    mountOptions = [
      "noatime"
      "logbsize=256k"
    ];
  };
in
{
  imports = [ inputs.disko.nixosModules.disko ];

  options.features.disko = {
    enable = mkEnableOption "declarative disk layout (disko)";

    isBTRFS = mkEnableOption "Uses BTRFS";
    isXFS = mkEnableOption "Uses XFS";

    primaryDrive = mkOption {
      type = str;
      default = "";
      description = "Primary drive hosting the root filesystem";
      example = "/dev/nvme0n1";
    };

    secondaryDrive = mkOption {
      type = str;
      default = "";
      description = "Secondary drive used as additional storage";
      example = "/dev/nvme1n1";
    };

    dualDrive = mkEnableOption "SecondaryDrive declaration";

    btrfs = {
      compression = mkOption {
        type = str;
        default = "zstd:3";
        description = "Btrfs compression algorithm and level";
      };
    };

    xfs = {
      secondaryMount = mkOption {
        type = str;
        default = "/secondary";
        description = "Mountpoint of the secondary XFS drive";
        example = "/data";
      };
    };

    swap = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable an optional swap partition";
      };
      size = mkOption {
        type = str;
        default = "8G";
        description = "Swap partition size";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.primaryDrive != "";
          message = "features.disko.primaryDrive must be set when disko is enabled";
        }
        {
          assertion = !cfg.dualDrive || cfg.secondaryDrive != "";
          message = "features.disko.secondaryDrive must be set when dualDrive is enabled";
        }
        {
          assertion = cfg.isBTRFS != cfg.isXFS;
          message = "features.disko: enable exactly one of isBTRFS or isXFS";
        }
      ];
    }
    (mkIf cfg.isBTRFS {
      disko.devices = {
        nodev."/" = {
          fsType = "tmpfs";
          mountOptions = [
            "size=40%"
            "mode=755"
          ];
        };
        disk = mkMerge [
          (primaryDisk btrfsRoot)
          (mkIf cfg.dualDrive (secondaryDisk null))
        ];
      };
      fileSystems = genAttrs [ "/nix" "/persistent" ] (_: {
        neededForBoot = true;
      });
    })
    (mkIf cfg.isXFS {
      disko.devices.disk = mkMerge [
        (primaryDisk xfsRoot)
        (mkIf cfg.dualDrive (secondaryDisk xfsSecondaryData))
      ];
    })
  ]);
}
