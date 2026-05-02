{ lib, config, ... }:

let
  cfg = config.optionals.features.kavita;
  domain = "moontier.online";

in
{
  options.optionals.features.kavita.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Kavita, an ebook/comic client, bundled with Komf metadata fetcher";
    default = false;
  };

  config = lib.mkMerge [
    {
      sops.secrets."kavita/token" = { };
    }

    (lib.mkIf cfg.enable {
      core.features.mediaPermissions.enable = true;
      networking.firewall.allowedTCPPorts = [
        3034
      ];

      services.nginx.virtualHosts."${domain}".locations."^~ /kavita/" = {
        proxyPass = "http://127.0.0.1:3034";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          aio threads;
        '';
      };

      systemd.services.kavita.serviceConfig.SupplementaryGroups = [ "media" ];
      services.kavita = {
        enable = true;
        settings = {
          baseUrl = "/kavita";
          Port = 3034;
        };
        tokenKeyFile = config.sops.secrets."kavita/token".path;
      };

    })
  ];
}
