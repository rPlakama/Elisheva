{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    types
    foldl'
    elem
    subtractLists
    optionalAttrs
    mkEnableOption
    ;
  inherit (types) listOf anything;

  cfg = config.features.preservation;
  diskoCfg = config.features.disko;
  user = config.core.user;

  fastTier = diskoCfg.dualDrive.enable && diskoCfg.dualDrive.fastDirs;

  # De-duplicate the persistence lists (defaults + any overrides).
  uniq = foldl' (acc: x: if elem x acc then acc else acc ++ [ x ]) [ ];

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

  # System state always goes to the fast tier (falls back to /persistent).
  systemDirs = uniq (defaultSystemDirs ++ cfg.system.directories);
  systemFiles = uniq (defaultSystemFiles ++ cfg.system.files);

  # Home is split: a small "fast" subset (defaults Projects/.config/.cache) on
  # the fast tier, the rest stays on /persistent.
  fastHomeDirs = cfg.fast.home.directories;
  fastHomeFiles = cfg.fast.home.files;
  persistentHomeDirs = uniq (subtractLists fastHomeDirs (defaultHomeDirs ++ cfg.home.directories));
  persistentHomeFiles = subtractLists fastHomeFiles cfg.home.files;

  # Everything merged, used when there is no fast tier.
  homeDirs = uniq (defaultHomeDirs ++ cfg.home.directories ++ fastHomeDirs);
  homeFiles = uniq (cfg.home.files ++ fastHomeFiles);

  userHome = directories: files: { users.${user} = { inherit directories files; }; };

  preserveAt =
    if fastTier then
      {
        "/fast" = {
          directories = systemDirs;
          files = systemFiles;
        }
        // userHome fastHomeDirs fastHomeFiles;
        "/persistent" = userHome persistentHomeDirs persistentHomeFiles;
      }
    else
      {
        "/persistent" = {
          directories = systemDirs;
          files = systemFiles;
        }
        // userHome homeDirs homeFiles;
      };
in
{
  options.features.preservation = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable impermanence with persistent state";
    };

    system = {
      directories = mkOption {
        type = listOf anything;
        default = [ ];
        description = "System directories to persist.";
        example = [ "/var/lib/qbittorrent" ];
      };
      files = mkOption {
        type = listOf anything;
        default = [ ];
        description = "System files to persist.";
        example = [ "/etc/adjtime" ];
      };
    };

    home = {
      directories = mkOption {
        type = listOf anything;
        default = [ ];
        description = "Home directories to persist.";
        example = [ ".config/vesktop" ];
      };
      files = mkOption {
        type = listOf anything;
        default = [ ];
        description = "Home files to persist.";
        example = [ ".gitconfig" ];
      };
    };

    fast.home = {
      directories = mkOption {
        type = listOf anything;
        default = [
          "Projects"
          ".cache"
        ];
        description = "Home directories to persist on the fast drive tier. Falls back to /persistent on hosts without the fast tier.";
        example = [ "Projects" ];
      };
      files = mkOption {
        type = listOf anything;
        default = [ ];
        description = "Home files to persist on the fast drive tier. Falls back to /persistent on hosts without the fast tier.";
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

    systemd.services.systemd-machine-id-commit.enable = false;

    preservation = {
      enable = true;
      inherit preserveAt;
    };
  };
}
