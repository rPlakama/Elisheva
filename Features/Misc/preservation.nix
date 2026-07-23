{
  config,
  lib,
  ...
}:
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
    "/var/lib/sops-nix"
    {
      directory = "/tmp";
      mode = "1777";
    }
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
    ".local"
    ".config"
    ".ssh"
  ];
in
{
  options.features.preservation = {
    enable = lib.mkEnableOption "impermanence with persistent state";

    system = {
      directories = lib.mkOption {
        type = lib.types.listOf lib.types.anything;
        default = [ ];
        description = "System directories to persist.";
        example = [ "/var/lib/qbittorrent" ];
      };
      files = lib.mkOption {
        type = lib.types.listOf lib.types.anything;
        default = [ ];
        description = "System files to persist.";
        example = [ "/etc/adjtime" ];
      };
    };

    home = {
      directories = lib.mkOption {
        type = lib.types.listOf lib.types.anything;
        default = [ ];
        description = "Home directories to persist.";
        example = [ ".config/vesktop" ];
      };
      files = lib.mkOption {
        type = lib.types.listOf lib.types.anything;
        default = [ ];
        description = "Home files to persist.";
        example = [ ".gitconfig" ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    nix.channel.enable = false;
    sops.age.sshKeyPaths = [ "/persistent/etc/ssh/ssh_host_ed25519_key" ];

    assertions = [
      {
        assertion = diskoCfg.enable;
        message = "features.preservation requires Disko to be enabled.";
      }
    ];

    preservation = {
      enable = true;
      preserveAt."/persistent" = {
        directories = defaultSystemDirs ++ cfg.system.directories;
        files = defaultSystemFiles ++ cfg.system.files;
        users.${user} = {
          directories = defaultHomeDirs ++ cfg.home.directories;
          files = cfg.home.files;
        };
      };
    };
  };
}
