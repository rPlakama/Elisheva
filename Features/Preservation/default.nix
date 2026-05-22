{ config, lib, ... }:
let
  diskoCfg = config.optionals.features.disko;
  preservationCfg = config.optionals.features.preservation;
  user = config.core.user;
  ssdOpts = lib.optionals diskoCfg.isSSD [
    "discard=async"
    "ssd"
  ];
in
{
  options.optionals.features = {
    disko = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable disko";
      };
      dualDrive = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable dual Drive Scheme";
      };
      primaryDrive = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Fastest Drive";
        example = "/dev/nvme0n1";
      };
      secondaryDrive = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Slowest Drive";
        example = "/dev/nvme1n1";
      };
      isSSD = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether drives are SSDs (enables discard=async and ssd mount options)";
      };
    };

    preservation = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.optionals.features.disko.enable;
        description = "Enable preservation for declarative persistent state";
      };
      additionalHomeDirs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Additional home directories to preserve (host-specific)";
        example = [
          ".config/vesktop"
          ".config/obs-studio"
        ];
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

  config = lib.mkMerge [
    (lib.mkIf diskoCfg.enable {
      fileSystems."/nix".neededForBoot = true;

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
            device = diskoCfg.primaryDrive;
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
                    (lib.mkIf (!diskoCfg.dualDrive) {
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

        (lib.mkIf diskoCfg.dualDrive {
          secondary = {
            device = diskoCfg.secondaryDrive;
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
    })

    (lib.mkIf preservationCfg.enable {
      fileSystems."/persist".neededForBoot = true;

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
          ++ preservationCfg.additionalDirs;

          files = [
            {
              file = "/etc/machine-id";
              inInitrd = true;
            }
          ]
          ++ preservationCfg.additionalFiles;

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
            ++ preservationCfg.additionalHomeDirs;
          };
        };
      };
    })
  ];
}
