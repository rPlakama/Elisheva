{
  config,
  lib,
  ...
}:
let
  cfg = config.features.preservation;
  diskoCfg = config.features.disko;
  user = config.core.user;

  fastTier = diskoCfg.dualDrive.enable && diskoCfg.dualDrive.splitFast;
  fastMountpoint = "/fast";

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
    ".cache"
    ".ssh"
  ];

  persistentHomeDirs =
    if fastTier then
      lib.subtractLists cfg.fast.home.directories (defaultHomeDirs ++ cfg.home.directories)
    else
      defaultHomeDirs ++ cfg.home.directories ++ cfg.fast.home.directories;
  persistentHomeFiles =
    if fastTier then
      lib.subtractLists cfg.fast.home.files (cfg.home.files)
    else
      cfg.home.files ++ cfg.fast.home.files;
  persistentSystemDirs =
    if fastTier then
      defaultSystemDirs ++ lib.subtractLists cfg.fast.system.directories cfg.system.directories
    else
      defaultSystemDirs ++ cfg.system.directories ++ cfg.fast.system.directories;
  persistentSystemFiles =
    if fastTier then
      defaultSystemFiles ++ lib.subtractLists cfg.fast.system.files cfg.system.files
    else
      defaultSystemFiles ++ cfg.system.files ++ cfg.fast.system.files;

  persistentRoot = {
    "/persistent" = {
      directories = persistentSystemDirs;
      files = persistentSystemFiles;
      users.${user} = {
        directories = persistentHomeDirs;
        files = persistentHomeFiles;
      };
    };
  };

  fastRoot = lib.optionalAttrs fastTier {
    ${fastMountpoint} = {
      directories = cfg.fast.system.directories;
      files = cfg.fast.system.files;
      users.${user} = {
        directories = cfg.fast.home.directories;
        files = cfg.fast.home.files;
      };
    };
  };

  preserveAt = persistentRoot // fastRoot;
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

    fast = {
      system = {
        directories = lib.mkOption {
          type = lib.types.listOf lib.types.anything;
          default = [ "/var/lib/libvirt" ];
          description = "System directories to persist on the fast drive tier (${fastMountpoint}). Falls back to /persistent on hosts without the fast tier.";
          example = [ "/var/lib/some-sqlite-db" ];
        };
        files = lib.mkOption {
          type = lib.types.listOf lib.types.anything;
          default = [ ];
          description = "System files to persist on the fast drive tier (${fastMountpoint}). Falls back to /persistent on hosts without the fast tier.";
          example = [ "/var/lib/some-state.db" ];
        };
      };
      home = {
        directories = lib.mkOption {
          type = lib.types.listOf lib.types.anything;
          default = [
            "Projects"
            ".config"
          ];
          description = "Home directories to persist on the fast drive tier (${fastMountpoint}). Falls back to /persistent on hosts without the fast tier.";
          example = [ "Projects" ];
        };
        files = lib.mkOption {
          type = lib.types.listOf lib.types.anything;
          default = [ ];
          description = "Home files to persist on the fast drive tier (${fastMountpoint}). Falls back to /persistent on hosts without the fast tier.";
          example = [ ".gitconfig" ];
        };
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

    systemd.services.systemd-machine-id-commit.enable = false;

    preservation = {
      enable = true;
      inherit preserveAt;
    };
  };
}
