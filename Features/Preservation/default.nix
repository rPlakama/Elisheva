{ config, lib, ... }:
let
  cfg = config.features.preservation;
  diskoCfg = config.features.disko;
  user = config.core.user;

  defaultSystemDirs = [
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
  ];

  defaultSystemFiles = [
    {
      file = "/etc/machine-id";
      inInitrd = true;
    }
  ];

  defaultHomeDirs = [
    "Downloads"
    "Projects"
    "Pictures"
    "Documents"
    "Videos"
    ".local/share"
    ".local/state"
    ".ssh"
  ];
in
{
  options.features.preservation = {
    enable = lib.mkEnableOption "impermanence with persistent state";

    persistDirs = {
      system = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "System directories to persist, declared by features";
        example = [ "/var/lib/qbittorrent" ];
      };
      home = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Home directories to persist, declared by features";
        example = [ ".config/vesktop" ];
      };
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

    # Wipe /tmp
    boot.tmp.cleanOnBoot = true;

    preservation = {
      enable = true;
      preserveAt."/persistent" = {
        directories = defaultSystemDirs ++ cfg.keepDirs.additionalDirs ++ cfg.persistDirs.system;
        files = defaultSystemFiles ++ cfg.keepDirs.additionalFiles;
        users.${user} = {
          directories = defaultHomeDirs ++ cfg.keepDirs.homeDirs ++ cfg.persistDirs.home;
        };
      };
    };
  };
}
