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
  stumpPort = 10801;
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
        services.suwayomi-server = {
          enable = true;
          package = pkgsM.suwayomi-server;
          settings = {
            server = {
              port = suwayomiPort;
              downloadAsCbz = true;
              downloadsPath = featureCall.library.downloadPath;
              extensionRepos = [
                "https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.min.json"
                "https://raw.githubusercontent.com/yuzono/manga-repo/repo/index.min.json"
                "https://raw.githubusercontent.com/LittleSurvival/copymanga-copy20/repo/index.min.json"
              ];
            };
          };
        };
      })
    ]
  );
}
