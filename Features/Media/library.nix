{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.features.library;
  kavitaPort = 3034;
  suwayomiPort = 4567;

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
    suwayomi.enable = lib.mkEnableOption "Suwayomi-Server (Tachidesk) manga reader";
  };
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        features = {
          preservation.system.directories = [ cfg.downloadPath ];
        };
        features.library = {
          kavita.enable = lib.mkDefault true;
          suwayomi.enable = lib.mkDefault true;
        };
      }
      (lib.mkIf cfg.kavita.enable {
        sops.secrets."kavita/token" = {
          owner = "kavita";
        };
        features = {
          mediaPermissions.enable = true;
          preservation.system.directories = [ "/var/lib/kavita" ];
          unifiedDNS.proxyServices.kavita = kavitaPort;
        };
        networking.firewall.allowedTCPPorts = [ kavitaPort ];
        systemd.services.kavita.serviceConfig.SupplementaryGroups = [ "media" ];
        services.kavita = {
          enable = true;
          tokenKeyFile = config.sops.secrets."kavita/token".path;
          settings.Port = kavitaPort;
        };
      })
      (lib.mkIf cfg.suwayomi.enable {
        features = {
          mediaPermissions.enable = true;
          preservation.system.directories = [ "/var/lib/suwayomi-server" ];
          unifiedDNS.proxyServices.suwayomi = suwayomiPort;
        };
        networking.firewall.allowedTCPPorts = [ suwayomiPort ];
        systemd.services.suwayomi-server.serviceConfig.SupplementaryGroups = [ "media" ];
        services.suwayomi-server = {
          enable = true;
          package = pkgs.suwayomi-server.overrideAttrs (old: {
            version = "2.3.2243";
            name = "suwayomi-server-2.3.2243";
            src = pkgs.fetchurl {
              url = "https://github.com/Suwayomi/Suwayomi-Server/releases/download/v2.3.2243/Suwayomi-Server-v2.3.2243.jar";
              hash = "sha256-ghFBsy4XDUoC08vf7Vd+2PB70iOD/19BMuu1rkDpjdU";
            };
            postFixup = ''
              sed -i 's|-Dsuwayomi.tachidesk.config.server.initialOpenInBrowserEnabled=false|-noverify -Xverify:none &|' $out/bin/tachidesk-server
            '';
          });
          settings = {
            server = {
              port = suwayomiPort;
              downloadAsCbz = true;
              downloadsPath = cfg.downloadPath;
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
