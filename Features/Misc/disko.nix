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
    count
    id
    ;
  inherit (lib.types)
    bool
    str
    listOf
    nullOr
    submodule
    ;

  cfg = config.features.disko;

  isBTRFS = cfg.format.BTRFS != null;
  isXFS = cfg.format.XFS != null;
  isImpermanence = cfg.mode.impermanence != null;
  isNormal = cfg.mode.normal != null;

  hasSingleFormat =
    count id [
      isBTRFS
      isXFS
    ] == 1;

  hasSingleMode =
    count id [
      isImpermanence
      isNormal
    ] == 1;

  validLayout =
    hasSingleFormat && hasSingleMode && !(isXFS && isImpermanence);

  # Optional swap partition appended to each drive's GPT.
  # When both primary and secondary drives are active, each drive gets a `swap.size`
  # partition (default 8G + 8G = 16G total) at equal priority (10, below zram's 100)
  # so the kernel stripes swap I/O round-robin across both NVMe drives.
  swapPartition = optionalAttrs cfg.swap.enable {
    swap = {
      size = cfg.swap.size;
      content =
        {
          type = "swap";
          resumeDevice = !cfg.dualDrive;
        }
        // optionalAttrs cfg.dualDrive {
          priority = 10;
          discardPolicy = "once";
        };
    };
  };

  # Bootable primary drive; `rootContent` is whatever ends up mounted on `/`,
  # and `extraPartitions` appends any additional fixed-size partitions (e.g. `/nix`).
  primaryDisk =
    {
      rootContent,
      extraPartitions ? { },
    }:
    {
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
          // extraPartitions
          // swapPartition;
        };
      };
    };

  # Secondary drive, either an unformatted partition joined into the impermanent
  # btrfs pool (`content = null`) or an independent filesystem in normal mode.
  # Named "0-secondary" so it sorts before "main": disko processes disks in
  # alphabetical order and mkfs.btrfs needs this partition to already exist.
  secondaryDisk = content: {
    "0-secondary" = {
      device = cfg.secondaryDrive;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          data = {
            name = "data";
            label = "SecondaryDrive";
            size = "100%";
            inherit content;
          };
        }
        // swapPartition;
      };
    };
  };

  btrfsMountOptions = [
    "noatime"
    "compress=${cfg.format.BTRFS.compression}"
    "ssd"
    "discard=async"
  ];

  # One btrfs pool spans both drives in impermanence mode: data single (files
  # land on one device, so a drive failure only costs its own files) + metadata raid1.
  btrfsImpermanentRoot = {
    type = "btrfs";
    extraArgs = [
      "-f"
    ]
    ++ optionals cfg.dualDrive [
      "-d"
      "single"
      "-m"
      "raid1"
      "/dev/disk/by-partlabel/SecondaryDrive"
    ];
    subvolumes = genAttrs [ "/nix" "/persistent" ] (mountpoint: {
      inherit mountpoint;
      mountOptions = btrfsMountOptions;
    });
  };

  btrfsNormalRoot = {
    type = "btrfs";
    extraArgs = [ "-f" ];
    mountpoint = "/";
    mountOptions = btrfsMountOptions;
  };

  btrfsNixPartition = {
    nix = {
      name = "nix";
      size = cfg.mode.normal.nixSize;
      content = {
        type = "btrfs";
        extraArgs = [ "-f" ];
        mountpoint = "/nix";
        mountOptions = btrfsMountOptions;
      };
    };
  };

  btrfsSecondaryData = {
    type = "btrfs";
    extraArgs = [ "-f" ];
    mountpoint = cfg.mode.normal.secondaryMount;
    mountOptions = btrfsMountOptions;
  };

  # XFS does not support subvolumes, so it cannot back an ephemeral (tmpfs) root.
  # noatime avoids atime metadata writes; logbsize batches metadata into larger
  # log buffers, trimming small random writes (helps DRAM-less NVMe a little).
  xfsRoot = {
    type = "filesystem";
    format = "xfs";
    mountpoint = "/";
    mountOptions = cfg.format.XFS.mountOptions;
  };

  xfsSecondaryData = {
    type = "filesystem";
    format = "xfs";
    mountpoint = cfg.mode.normal.secondaryMount;
    mountOptions = cfg.format.XFS.mountOptions;
  };
in
{
  imports = [ inputs.disko.nixosModules.disko ];

  options.features.disko = {
    enable = mkEnableOption "declarative disk layout (disko)";

    format = {
      BTRFS = mkOption {
        type = nullOr (submodule {
          options = {
            compression = mkOption {
              type = str;
              default = "zstd:3";
              description = "Btrfs compression algorithm and level";
            };
          };
        });
        default = null;
        description = "Use BTRFS filesystem (declare as `{ ... }` or `{ }`)";
      };

      XFS = mkOption {
        type = nullOr (submodule {
          options = {
            mountOptions = mkOption {
              type = listOf str;
              default = [
                "noatime"
                "logbufs=8"
                "logbsize=256k"
              ];
              description = "XFS mount options";
            };
          };
        });
        default = null;
        description = "Use XFS filesystem (declare as `{ ... }` or `{ }`)";
      };
    };

    mode = {
      impermanence = mkOption {
        type = nullOr (submodule {
          options = {
            tmpfsSize = mkOption {
              type = str;
              default = "40%";
              description = "Size of the ephemeral tmpfs root";
            };
          };
        });
        default = null;
        description = "Ephemeral tmpfs root with persistent /nix and /persistent subvolumes (declare as `{ ... }` or `{ }`)";
      };

      normal = mkOption {
        type = nullOr (submodule {
          options = {
            nixSize = mkOption {
              type = str;
              default = "64G";
              description = "Size of the dedicated BTRFS /nix partition";
            };
            secondaryMount = mkOption {
              type = str;
              default = "/secondary";
              description = "Mountpoint of the secondary drive";
              example = "/data";
            };
          };
        });
        default = null;
        description = "Stateful root filesystem (declare as `{ ... }` or `{ }`)";
      };
    };

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

    swap = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable an optional swap partition";
      };
      size = mkOption {
        type = str;
        default = "8G";
        description = "Swap partition size per drive (dual-drive setups create one per drive for 2x total)";
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
          assertion = hasSingleFormat;
          message = "features.disko.format: declare exactly one of BTRFS or XFS";
        }
        {
          assertion = hasSingleMode;
          message = "features.disko.mode: declare exactly one of impermanence or normal";
        }
        {
          assertion = !(isXFS && isImpermanence);
          message = "features.disko: mode.impermanence requires format.BTRFS (XFS does not support subvolumes)";
        }
      ];
    }
    (mkIf (validLayout && isBTRFS && isImpermanence) {
      disko.devices = {
        nodev."/" = {
          fsType = "tmpfs";
          mountOptions = [
            "size=${cfg.mode.impermanence.tmpfsSize}"
            "mode=755"
          ];
        };
        disk = mkMerge [
          (primaryDisk { rootContent = btrfsImpermanentRoot; })
          (mkIf cfg.dualDrive (secondaryDisk null))
        ];
      };
      fileSystems = genAttrs [ "/nix" "/persistent" ] (_: {
        neededForBoot = true;
      });
    })
    (mkIf (validLayout && isBTRFS && isNormal) {
      disko.devices.disk = mkMerge [
        (primaryDisk {
          rootContent = btrfsNormalRoot;
          extraPartitions = btrfsNixPartition;
        })
        (mkIf cfg.dualDrive (secondaryDisk btrfsSecondaryData))
      ];
      fileSystems."/nix".neededForBoot = true;
    })
    (mkIf (validLayout && isXFS && isNormal) {
      disko.devices.disk = mkMerge [
        (primaryDisk { rootContent = xfsRoot; })
        (mkIf cfg.dualDrive (secondaryDisk xfsSecondaryData))
      ];
    })
  ]);
}
