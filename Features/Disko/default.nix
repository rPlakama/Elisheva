{ config, lib, ... }:
let
  diskoCfg = config.optionals.features.disko;
  ssdOpts = lib.optionals diskoCfg.isSSD [
    "discard=async"
    "ssd"
  ];
in
{
  options.optionals.features.disko = {
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
      description = "Spread /nix and /persist across separate drives";
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
      description = "Secondary drive for /persist (dual-drive mode)";
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
      {
        main = {
          device = diskoCfg.primaryDrive;
          type = "disk";
          content.type = "gpt";
          content.partitions = lib.mkMerge [
            {
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
            }
            (lib.mkIf diskoCfg.swap.enable {
              swap = {
                size = diskoCfg.swap.size;
                content = {
                  type = "swap";
                  resumeDevice = true;
                };
              };
            })
            {
              root = {
                name = "root";
                size = "100%";
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = lib.mkMerge [
                    {
                      "/nix" = {
                        mountOptions = [ "noatime" ] ++ ssdOpts;
                        mountpoint = "/nix";
                      };
                    }
                    (lib.mkIf (!diskoCfg.dualDrive) {
                      "/persist" = {
                        mountOptions = [ "noatime" ] ++ ssdOpts;
                        mountpoint = "/persist";
                      };
                    })
                  ];
                };
              };
            }
          ];
        };
      }

      (lib.mkIf diskoCfg.dualDrive {
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
                  "/persist" = {
                    mountOptions = [ "noatime" ] ++ ssdOpts;
                    mountpoint = "/persist";
                  };
                };
              };
            };
          };
        };
      })
    ];
  };
}
