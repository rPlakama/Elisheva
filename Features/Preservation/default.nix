{ config, lib, ... }:
let
  cfg = config.optionals.features.preservation;
  diskoCfg = config.optionals.features.disko;
  user = config.core.user;

  # --- State preserved

  defaultSystemDirs = [
    "/etc/nixos"
    "/var/lib/tailscale"
    "/var/lib/bluetooth"
    "/var/log"
    "/etc/NetworkManager/system-connections"
    "/etc/ssh"
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

  tmpfsRoot = {
    fsType = "tmpfs";
    mountOptions = [
      "size=25%"
      "mode=755"
    ];
  };
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
      "/persistent".neededForBoot = true;
      "/tmp".neededForBoot = true;
    };

    boot.tmp.cleanOnBoot = true;
    disko.devices.nodev."/" = tmpfsRoot;

    preservation = {
      enable = true;
      preserveAt."/persistent" = {
        directories = defaultSystemDirs ++ cfg.keepDirs.additionalDirs;
        files = defaultSystemFiles ++ cfg.keepDirs.additionalFiles;
        users.${user}.directories = defaultHomeDirs ++ cfg.keepDirs.homeDirs;
      };
    };
  };
}
