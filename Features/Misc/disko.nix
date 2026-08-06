{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    mkEnableOption
    mkMerge
    optionalAttrs
    optional
    optionals
    genAttrs
    ;
  inherit (lib.types)
    bool
    str
    coercedTo
    submodule
    ;

  diskoCfg = config.features.disko;
  dual = diskoCfg.dualDrive;
  fastEnabled = dual.enable && dual.fastDirs;

  # Mount options for a btrfs subvolume; disko appends the subvol mountpoint.
  subvolOpts =
    isSSD:
    [
      "noatime"
      "compress=${diskoCfg.compression}"
    ]
    ++ optionals isSSD [
      "discard=async"
      "ssd"
    ];

  # A subvolume entry keyed by its mountpoint.
  subvol = mount: isSSD: {
    mountOptions = subvolOpts isSSD;
    mountpoint = mount;
  };

  # Subvolumes on the primary (fast) drive: /nix always, plus /persistent
  # unless it belongs on the secondary drive, plus /fast when split is on.
  primarySubvols = {
    "/nix" = subvol "/nix" diskoCfg.isSSD.primary;
  }
  // optionalAttrs (!dual.enable) { "/persistent" = subvol "/persistent" diskoCfg.isSSD.primary; }
  // optionalAttrs fastEnabled { "/fast" = subvol "/fast" diskoCfg.isSSD.primary; };

  btrfsPartition = {
    extraArgs = [ "-f" ];
    type = "btrfs";
  };

  primaryDisk = {
    main = {
      device = diskoCfg.primaryDrive;
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
            size = "100%";
            content = (btrfsPartition // { subvolumes = primarySubvols; });
          };
        }
        // optionalAttrs diskoCfg.swap.enable {
          swap = {
            size = diskoCfg.swap.size;
            content = {
              type = "swap";
              resumeDevice = true;
            };
          };
        };
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
          content = btrfsPartition // {
            subvolumes = {
              "/persistent" = subvol "/persistent" diskoCfg.isSSD.secondary;
            };
          };
        };
      };
    };
  };

  neededForBoot = [
    "/nix"
    "/persistent"
  ]
  ++ optional fastEnabled "/fast";
in
{
  options.features.disko = {
    enable = mkEnableOption "declarative disk layout (disko)";
    isSSD = {
      primary = mkOption {
        type = bool;
        default = true;
        description = "Whether the primary drive is an SSD (enables discard=async and ssd mount options)";
      };
      secondary = mkOption {
        type = bool;
        default = true;
        description = "Whether the secondary drive is an SSD (enables discard=async and ssd mount options)";
      };
    };
    dualDrive = mkOption {
      description = "Spread /nix and /persistent across separate drives";
      default = {
        enable = false;
        fastDirs = false;
      };
      type =
        coercedTo bool
          (enable: {
            inherit enable;
            fastDirs = false;
          })
          (submodule {
            options = {
              enable = mkOption {
                type = bool;
                default = false;
                description = "Spread /nix and /persistent across separate drives";
              };
              fastDirs = mkOption {
                type = bool;
                default = false;
                description = "Give /fast its own subvolume on the primary drive";
              };
            };
          });
    };
    primaryDrive = mkOption {
      type = str;
      default = "";
      description = "Primary/fastest drive";
      example = "/dev/nvme0n1";
    };
    secondaryDrive = mkOption {
      type = str;
      default = "";
      description = "Secondary drive for /persistent (dual-drive mode)";
      example = "/dev/nvme1n1";
    };
    compression = mkOption {
      type = str;
      default = "zstd:3";
      description = "Btrfs compression algorithm and level";
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

  config = mkIf diskoCfg.enable {
    assertions = [
      {
        assertion = diskoCfg.primaryDrive != "";
        message = "features.disko.primaryDrive must be set when disko is enabled";
      }
      {
        assertion = !dual.enable || diskoCfg.secondaryDrive != "";
        message = "features.disko.secondaryDrive must be set when dualDrive is enabled";
      }
    ];
    disko.devices = {
      nodev."/" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=40%"
          "mode=755"
        ];
      };
      disk = mkMerge [
        primaryDisk
        (mkIf dual.enable secondaryDisk)
      ];
    };
    fileSystems = genAttrs neededForBoot (m: {
      neededForBoot = true;
    });
  };
}
