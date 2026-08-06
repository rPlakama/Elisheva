{
  config,
  lib,
  ...
}:
let
  diskoCfg = config.features.disko;
  dual = diskoCfg.dualDrive;
  fastEnabled = dual.enable && dual.splitFast;

  # Mount options for a btrfs subvolume; disko appends the subvol mountpoint.
  subvolOpts = isSSD:
    [ "noatime" "compress=${diskoCfg.compression}" ]
    ++ lib.optionals isSSD [
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
  primarySubvols =
    { "/nix" = subvol "/nix" diskoCfg.isSSD.primary; }
    // lib.optionalAttrs (!dual.enable) { "/persistent" = subvol "/persistent" diskoCfg.isSSD.primary; }
    // lib.optionalAttrs fastEnabled { "/fast" = subvol "/fast" diskoCfg.isSSD.primary; };

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
          boot = { name = "boot"; size = "1M"; type = "EF02"; };
          esp = {
            name = "ESP";
            size = "1G";
            type = "EF00";
            content = { type = "filesystem"; format = "vfat"; mountpoint = "/boot"; };
          };
          root = {
            name = "root";
            size = "100%";
            content = (btrfsPartition // { subvolumes = primarySubvols; });
          };
        } // lib.optionalAttrs diskoCfg.swap.enable {
          swap = {
            size = diskoCfg.swap.size;
            content = { type = "swap"; resumeDevice = true; };
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
            subvolumes = { "/persistent" = subvol "/persistent" diskoCfg.isSSD.secondary; };
          };
        };
      };
    };
  };

  neededForBoot = [ "/nix" "/persistent" ] ++ lib.optional fastEnabled "/fast";
in
{
  options.features.disko = {
    enable = lib.mkEnableOption "declarative disk layout (disko)";
    isSSD = {
      primary = lib.mkOption { type = lib.types.bool; default = true; description = "Whether the primary drive is an SSD (enables discard=async and ssd mount options)"; };
      secondary = lib.mkOption { type = lib.types.bool; default = true; description = "Whether the secondary drive is an SSD (enables discard=async and ssd mount options)"; };
    };
    dualDrive = lib.mkOption {
      description = "Spread /nix and /persistent across separate drives";
      default = { enable = false; splitFast = false; };
      type = lib.types.coercedTo lib.types.bool
        (enable: { inherit enable; splitFast = false; })
        (lib.types.submodule {
          options = {
            enable = lib.mkOption { type = lib.types.bool; default = false; description = "Spread /nix and /persistent across separate drives"; };
            splitFast = lib.mkOption { type = lib.types.bool; default = false; description = "Give /fast its own subvolume on the primary drive"; };
          };
        });
    };
    primaryDrive = lib.mkOption { type = lib.types.str; default = ""; description = "Primary/fastest drive"; example = "/dev/nvme0n1"; };
    secondaryDrive = lib.mkOption { type = lib.types.str; default = ""; description = "Secondary drive for /persistent (dual-drive mode)"; example = "/dev/nvme1n1"; };
    compression = lib.mkOption { type = lib.types.str; default = "zstd:3"; description = "Btrfs compression algorithm and level"; };
    swap = {
      enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable an optional swap partition"; };
      size = lib.mkOption { type = lib.types.str; default = "8G"; description = "Swap partition size"; };
    };
  };

  config = lib.mkIf diskoCfg.enable {
    assertions = [
      { assertion = diskoCfg.primaryDrive != ""; message = "features.disko.primaryDrive must be set when disko is enabled"; }
      { assertion = !dual.enable || diskoCfg.secondaryDrive != ""; message = "features.disko.secondaryDrive must be set when dualDrive is enabled"; }
    ];
    disko.devices = {
      nodev."/" = { fsType = "tmpfs"; mountOptions = [ "size=40%" "mode=755" ]; };
      disk = lib.mkMerge [
        primaryDisk
        (lib.mkIf dual.enable secondaryDisk)
      ];
    };
    fileSystems = lib.genAttrs neededForBoot (m: { neededForBoot = true; });
  };
}