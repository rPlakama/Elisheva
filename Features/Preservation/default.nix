{ config, lib, ... }:
let
  cfg = config.features.preservation;
  diskoCfg = config.features.disko;
  user = config.core.user;

  # --- State preserved between rebuilds ---

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
  options.features.preservation = {
    enable = lib.mkEnableOption "impermanence with persistent state";
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
        directories = defaultSystemDirs ++ cfg.keepDirs.additionalDirs
          ++ lib.optionals config.features.samba.enable [ "/var/lib/samba" ]
          ++ lib.optionals config.features.jellyfin.enable [ "/var/lib/jellyfin" ]
          ++ lib.optionals config.features.slskd.enable [ "/var/lib/slskd" ]
          ++ lib.optionals config.features.nextcloud.enable [ "/var/lib/nextcloud" "/var/lib/postgresql" ]
          ++ lib.optionals config.features.kavita.enable [ "/var/lib/kavita" ]
          ++ lib.optionals config.features.qbit.enable [ "/var/lib/qbittorrent" "/var/lib/qui" ]
          ++ lib.optionals config.features.rrstack.enable [ "/var/lib/jackett" "/var/lib/sonarr" "/var/lib/radarr" "/var/lib/prowlarr" ]
          ++ lib.optionals config.features.st.enable [ "/var/lib/SillyTavern" ]
          ++ lib.optionals config.features.nzbget.enable [ "/var/lib/nzbget" ]
          ++ lib.optionals config.features.virtualization.enable [ "/var/lib/docker" ]
          ++ lib.optionals config.features.unifiedDNS.enable [ "/etc/pihole" "/var/lib/acme" ]
        ;

        files = defaultSystemFiles ++ cfg.keepDirs.additionalFiles;

        users.${user} = {
          directories = defaultHomeDirs ++ cfg.keepDirs.homeDirs
            ++ lib.optionals config.features.graphicalPkgs.enable [ ".config/vesktop" "/home/${user}/Nextcloud" ]
            ++ lib.optionals config.features.niri.enable [ ".config/niri" ]
            ++ lib.optionals config.features.dankMaterialShell.enable [ ".config/dank-material-shell" ]
            ++ lib.optionals config.features.whatsBot.enable [ "bot-ascending" ]
            ++ lib.optionals config.features.gpuScreenRecorder.enable [ ".config/gpu-screen-recorder" ]
            ++ lib.optionals config.features.sunshine.enable [ ".config/sunshine" ]
          ;
        };
      };
    };
  };
}
