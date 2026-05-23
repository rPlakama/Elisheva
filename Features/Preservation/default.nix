{ config, lib, ... }:
let
  cfg = config.optionals.features.preservation;
  diskoCfg = config.optionals.features.disko;
  user = config.core.user;
in
{
  options.optionals.features.preservation = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable impermanence with persistent state";
    };
    keepDirs = {
      homeDirs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Additional home directories to preserve";
        example = [ ".config/vesktop" ];
      };
      additionalDirs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Additional system directories to preserve";
        example = [ "/var/lib/docker" ];
      };
      additionalFiles = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Additional system files to preserve";
        example = [ "/etc/adjtime" ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = diskoCfg.enable;
        message = "Requires Disko enabled to be used";
      }
    ];

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
