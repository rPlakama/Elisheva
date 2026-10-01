{
  lib,
  config,
  pkgsM,
  ...
}:
let
  featureCall = config.features;
  kavitaPort = 3034;
  suwayomiPort = 4567;
  suwayomiID = 2002;
  suwayomiContainerPort = 8882;
  suwayomiDataDir = "/var/lib/suwayomi/suwayomi-server";
  mediaGid = config.users.groups.media.gid;
  stumpPort = 10801;
  localHost = "127.0.0.1";
in
{
  options.features.library = {
    enable = lib.mkEnableOption "Library Master Switch";
    downloadPath = lib.mkOption {
      type = lib.types.str;
      default = "/media/literature/mangas";
      description = "Download path for library downloads";
    };
    kavita.enable = lib.mkEnableOption "Kavita self-hosted digital library";
    stump.enable = lib.mkEnableOption "Stump free and open source comics, manga and digital book server with OPDS support";
    suwayomi.enable = lib.mkEnableOption "Suwayomi-Server (Tachidesk) manga reader";
  };
  config = lib.mkIf featureCall.library.enable (
    lib.mkMerge [
      {
        features = {
          preservation.system.directories = [ featureCall.library.downloadPath ];
        };
      }
      (lib.mkIf featureCall.library.stump.enable {
        features = {
          mediaPermissions = {
            enable = true;
            writableServices = [ "stump" ];
          };
          preservation.system.directories = [ "/var/lib/stump" ];
          unifiedDNS.proxyServices.stump = {
            port = stumpPort;
            icon = "sh-stump";
            description = "Comics, manga and digital book server";
          };
        };
        services.stump = {
          enable = true;
          group = "media";
          port = stumpPort;
          environment.STUMP_TRUST_PROXY_HEADERS = "true";
        };
      })
      (lib.mkIf featureCall.library.kavita.enable {
        sops.secrets."kavita/token" = {
          owner = "kavita";
        };
        features = {
          mediaPermissions.enable = true;
          preservation.system.directories = [ "/var/lib/kavita" ];
          unifiedDNS.proxyServices.kavita = {
            port = kavitaPort;
            icon = "sh-kavita";
            description = "Ebook and manga library";
          };
        };
        systemd.services.kavita.serviceConfig.SupplementaryGroups = [ "media" ];
        services.kavita = {
          enable = true;
          tokenKeyFile = config.sops.secrets."kavita/token".path;
          settings.Port = kavitaPort;
        };
      })
      (lib.mkIf featureCall.library.suwayomi.enable {
        features = {
          mediaPermissions.enable = true;
          preservation.system.directories = [ "/var/lib/suwayomi-server" ];
          unifiedDNS.proxyServices.suwayomi = {
            port = suwayomiPort;
            icon = "sh-suwayomi";
            description = "Manga reader (Suwayomi-Server)";
          };
        };
        systemd.services.suwayomi-server.serviceConfig.SupplementaryGroups = [ "media" ];

        virtualisation = {
          oci-containers = {
            backend = "docker";
            containers.suwayomi-server = {
              image = "suwayomi/suwayomi-server:latest";
              user = "${toString suwayomiID}:${toString mediaGid}";
              ports = [ "${localHost}:${toString suwayomiPort}:${toString suwayomiContainerPort}" ];
              volumes = [
                "${suwayomiDataDir}/downloads:/home/suwayomi/.local/share/Tachidesk/downloads"
                "${suwayomiDataDir}/files:/home/suwayomi/.local/share/T"
              ];
              environment = {
                PUID = toString suwayomiID;
                PGID = toString mediaGid;
                TZ = config.time.timeZone;
              };
              devices = [ "/dev/dri:/dev/dri" ];
            };
          };
        };

      })
    ]
  );
}
