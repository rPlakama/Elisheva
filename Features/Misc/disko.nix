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
    optionals
    genAttrs
    ;
  inherit (lib.types)
    bool
    str
    ;

  featureCall = config.features;

  # Partition 1 of the secondary drive, e.g. /dev/nvme0n1 -> /dev/nvme0n1p1.
  secondaryPart =
    let
      dev = featureCall.disko.secondaryDrive;
    in
    if builtins.match ".*[0-9]$" dev != null then "${dev}p1" else "${dev}1";

  # One btrfs pool spans both drives: data single (files land on one device,
  # so a drive failure only costs its own files) + metadata raid1.
  poolExtraArgs =
    [ "-f" ]
    ++ optionals featureCall.disko.dualDrive [
      "-d"
      "single"
      "-m"
      "raid1"
      secondaryPart
    ];

  btrfsOpts = [
    "noatime"
    "compress=${featureCall.disko.compression}"
    "ssd"
    "discard=async"
  ];

  subvol = mount: {
    mountOptions = btrfsOpts;
    mountpoint = mount;
  };

  poolSubvols = {
    "/nix" = subvol "/nix";
    "/persistent" = subvol "/persistent";
  };

  primaryDisk = {
    main = {
      device = featureCall.disko.primaryDrive;
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
            content = {
              type = "btrfs";
              extraArgs = poolExtraArgs;
              subvolumes = poolSubvols;
            };
          };
        }
        // optionalAttrs featureCall.disko.swap.enable {
          swap = {
            size = featureCall.disko.swap.size;
            content = {
              type = "swap";
              resumeDevice = true;
            };
          };
        };
      };
    };
  };

  # The secondary drive contributes an unformatted partition to the pool.
  # Named "0-secondary" so it sorts before "main": disko processes disks in
  # alphabetical order, and mkfs.btrfs needs this partition to already exist.
  secondaryDisk = {
    "0-secondary" = {
      device = featureCall.disko.secondaryDrive;
      type = "disk";
      content = {
        type = "gpt";
        partitions.data = {
          name = "data";
          size = "100%";
        };
      };
    };
  };
in
{
  options.features.disko = {
    enable = mkEnableOption "declarative disk layout (disko)";
    primaryDrive = mkOption {
      type = str;
      default = "";
      description = "Primary drive hosting the btrfs pool";
      example = "/dev/nvme0n1";
    };
    secondaryDrive = mkOption {
      type = str;
      default = "";
      description = "Second drive joined into the btrfs pool (dual-drive mode)";
      example = "/dev/nvme1n1";
    };
    dualDrive = mkEnableOption "join a second drive into the btrfs pool (data single, metadata raid1)";
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

  config = mkIf featureCall.disko.enable {
    assertions = [
      {
        assertion = featureCall.disko.primaryDrive != "";
        message = "features.disko.primaryDrive must be set when disko is enabled";
      }
      {
        assertion = !featureCall.disko.dualDrive || featureCall.disko.secondaryDrive != "";
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
        (mkIf featureCall.disko.dualDrive secondaryDisk)
      ];
    };
    fileSystems = genAttrs [
      "/nix"
      "/persistent"
    ] (m: {
      neededForBoot = true;
    });
  };
}
