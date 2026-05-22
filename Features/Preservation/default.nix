{ config, lib, ... }:
let
  cfg = config.optionals.features.preservation;
  diskoCfg = config.optionals.features.disko;
  user = config.core.user;
  ssdOpts = lib.optionals diskoCfg.isSSD [
    "discard=async"
    "ssd"
  ];
in
{
  options.optionals.features = {
    disko.isSSD = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether drives are SSDs (enables discard=async and ssd mount options)";
    };

    preservation = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable declarative disk layout and persistent state";
      };
      dualDrive = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable dual drive scheme";
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
        description = "Secondary/slowest drive";
        example = "/dev/nvme1n1";
      };
      keepDirs = {
        homeDirs = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Additional home directories to preserve (host-specific)";
          example = [ ".config/vesktop" ];
        };
        additionalDirs = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Additional system directories to preserve (host-specific)";
          example = [ "/var/lib/docker" ];
        };
        additionalFiles = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Additional system files to preserve (host-specific)";
          example = [ "/etc/adjtime" ];
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    fileSystems = {
      "/nix".neededForBoot = true;
      "/persist".neededForBoot = true;
    };

    disko.devices.nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=25%"
        "mode=755"
      ];
    };

    disko.devices.disk = lib.mkMerge [
      {
        main = {
          device = cfg.primaryDrive;
          type = "disk";
          content.type = "gpt";
          content.partitions = {
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
            swap = {
              size = "16G";
              content = {
                type = "swap";
                resumeDevice = true;
              };
            };
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
                  (lib.mkIf (!cfg.dualDrive) {
                    "/persist" = {
                      mountOptions = [ "noatime" ] ++ ssdOpts;
                      mountpoint = "/persist";
                    };
                  })
                ];
              };
            };
          };
        };
      }

      (lib.mkIf cfg.dualDrive {
        secondary = {
          device = cfg.secondaryDrive;
          type = "disk";
          content.type = "gpt";
          content.partitions.data = {
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
      })
    ];

    preservation = {
      enable = true;
      preserveAt."/persist" = {
        directories = [
          "/etc/nixos"
          "/var/lib/tailscale"
          "/var/lib/bluetooth"
          "/var/log"
          "/etc/NetworkManager/system-connections"
          "/etc/ssh"
          "/tmp"
          {
            directory = "/var/lib/nixos";
            inInitrd = true;
          }
        ]
        ++ cfg.keepDirs.additionalDirs;

        files = [
          {
            file = "/etc/machine-id";
            inInitrd = true;
          }
        ]
        ++ cfg.keepDirs.additionalFiles;

        users.${user} = {
          directories = [
            "Downloads"
            "Projects"
            "Pictures"
            "Documents"
            "Music"
            "Videos"
            ".local/share"
            ".local/state"
            ".cache"
            ".ssh"
            ".gnupg"
          ]
          ++ cfg.keepDirs.homeDirs;
        };
      };
    };
  };
}
