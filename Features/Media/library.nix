{
  lib,
  config,
  ...
}:
let
  cfg = config.features.library;
  kavitaPort = 3034;
  suwayomiPort = 4567;
in
{
  # --- Options ---
  options.features.library = {
    enable = lib.mkEnableOption "Library Master Switch";

    kavita = {
      enable = lib.mkEnableOption "Kavita self-hosted digital library";
    };

    suwayomi = {
      enable = lib.mkEnableOption "Suwayomi-Server (Tachidesk) manga reader";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
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
          unifiedDNS.proxyServices = {
            kavita = kavitaPort;
          };
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
          unifiedDNS.proxyServices = {
            suwayomi = suwayomiPort;
          };
        };

        networking.firewall.allowedTCPPorts = [ suwayomiPort ];
        systemd.services.suwayomi-server.serviceConfig.SupplementaryGroups = [ "media" ];

        services.suwayomi-server = {
          enable = true;
          settings = {
            server.port = suwayomiPort;
          };
        };
      })
    ]
  );
}
