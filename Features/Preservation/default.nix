{ config, lib, ... }:
let
  diskoCfg = config.optionals.features.disko;
  preservationCfg = config.optionals.features.preservation;
  user = config.core.user;
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
        description = "Enable dual Driver Scheme";
      };
      primaryDrive = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Fatest Driver";
        example = "/dev/nvme0n1";
      };
      secondaryDrive = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Slowest Driver";
        example = "/dev/nvme1n1";
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
              nix = {
                name = "nix";
                size = "100%";
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes."/nix" = {
                    mountOptions = [
                      "subvol=nix"
                      "noatime"
                      "compress=zstd"
                    ];
                    mountpoint = "/nix";
                  };
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
                    mountOptions = [
                      "subvol=persist"
                      "noatime"
                      "compress=zstd"
                    ];
                    mountpoint = "/persist";
                  };
                  "/home" = {
                    mountOptions = [
                      "subvol=home"
                      "noatime"
                      "compress=zstd"
                    ];
                    mountpoint = "/home";
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

      preservation.enable = true;

      preservation.preserveAt."/persist" = {
        directories = [
          "/var/lib/tailscale"
          "/var/lib/bluetooth"
          "/var/lib/nixos"
          "/var/log"
          "/etc/NetworkManager/system-connections"
          "/etc/ssh"
        ]
        ++ preservationCfg.additionalDirs;

        files = [
          "/etc/machine-id"
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
    })
  ];
}
