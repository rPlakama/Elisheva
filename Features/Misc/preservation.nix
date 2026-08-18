{
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkOption
    types
    foldl'
    elem
    ;
  inherit (types) listOf anything;

  featureCall = config.features;
  user = config.core.user;

  # De-duplicate the persistence lists (defaults + any overrides).
  uniq = foldl' (acc: x:
    if elem x acc
    then acc
    else acc ++ [x]) [];

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
    "Media"
    "Projects"
    "Pictures"
    "Documents"
    "Videos"
    ".local"
    ".config"
    ".cache"
    ".ssh"
  ];

  systemDirs = uniq (defaultSystemDirs ++ featureCall.preservation.system.directories);
  systemFiles = uniq (defaultSystemFiles ++ featureCall.preservation.system.files);
  homeDirs = uniq (defaultHomeDirs ++ featureCall.preservation.home.directories);
  homeFiles = uniq (featureCall.preservation.home.files);

  userHome = directories: files: {users.${user} = {inherit directories files;};};

  preserveAt = {
    "/persistent" =
      {
        directories = systemDirs;
        files = systemFiles;
      }
      // userHome homeDirs homeFiles;
  };
in {
  options.features.preservation = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable impermanence with persistent state";
    };

    system = {
      directories = mkOption {
        type = listOf anything;
        default = [];
        description = "System directories to persist.";
        example = ["/var/lib/qbittorrent"];
      };
      files = mkOption {
        type = listOf anything;
        default = [];
        description = "System files to persist.";
        example = ["/etc/adjtime"];
      };
    };

    home = {
      directories = mkOption {
        type = listOf anything;
        default = [];
        description = "Home directories to persist.";
        example = [".config/vesktop"];
      };
      files = mkOption {
        type = listOf anything;
        default = [];
        description = "Home files to persist.";
        example = [".gitconfig"];
      };
    };
  };

  config = lib.mkIf featureCall.preservation.enable {
    nix.channel.enable = false;
    sops.age.sshKeyPaths = ["/persistent/etc/ssh/ssh_host_ed25519_key"];
    assertions = [
      {
        assertion = featureCall.disko.enable;
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
