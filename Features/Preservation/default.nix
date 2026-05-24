{ config, lib, ... }:
let
  cfg = config.features.preservation;
  diskoCfg = config.features.disko;
  user = config.core.user;
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
  config = lib.mkIf cfg.enable (
    let
      whenEnabled = feature: dirs: lib.optionals config.features.${feature}.enable dirs;
      uncurry = f: pair: f (lib.elemAt pair 0) (lib.elemAt pair 1);
    in
    {
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
          directories =
            defaultSystemDirs
            ++ cfg.keepDirs.additionalDirs
            ++ lib.concatMap (uncurry whenEnabled) [
              [
                "samba"
                [ "/var/lib/samba" ]
              ]
              [
                "jellyfin"
                [ "/var/lib/jellyfin" ]
              ]
              [
                "slskd"
                [ "/var/lib/slskd" ]
              ]
              [
                "nextcloud"
                [
                  "/var/lib/nextcloud"
                  "/var/lib/postgresql"
                ]
              ]
              [
                "kavita"
                [ "/var/lib/kavita" ]
              ]
              [
                "qbit"
                [
                  "/var/lib/qbittorrent"
                  "/var/lib/qui"
                ]
              ]
              [
                "rrstack"
                [
                  "/var/lib/jackett"
                  "/var/lib/sonarr"
                  "/var/lib/radarr"
                  "/var/lib/prowlarr"
                ]
              ]
              [
                "st"
                [ "/var/lib/SillyTavern" ]
              ]
              [
                "nzbget"
                [ "/var/lib/nzbget" ]
              ]
              [
                "virtualization"
                [ "/var/lib/docker" ]
              ]
              [
                "unifiedDNS"
                [
                  "/etc/pihole"
                  "/var/lib/acme"
                ]
              ]
            ];
          files = defaultSystemFiles ++ cfg.keepDirs.additionalFiles;
          users.${user} = {
            directories =
              defaultHomeDirs
              ++ cfg.keepDirs.homeDirs
              ++ lib.concatMap (uncurry whenEnabled) [
                [
                  "graphicalPkgs"
                  [
                    ".config/vesktop"
                    "Nextcloud"
                  ]
                ]
                [
                  "niri"
                  [ ".config/niri" ]
                ]
                [
                  "dankMaterialShell"
                  [ ".config/dank-material-shell" ]
                ]
                [
                  "whatsBot"
                  [ "bot-ascending" ]
                ]
                [
                  "gpuScreenRecorder"
                  [ ".config/gpu-screen-recorder" ]
                ]
                [
                  "sunshine"
                  [ ".config/sunshine" ]
                ]
              ];
          };
        };
      };
    }
  );
}
