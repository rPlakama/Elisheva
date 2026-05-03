{ lib, config, ... }:

let
  cfg = config.optionals.features.kavita;
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
      systemd.services.kavita.serviceConfig.SupplementaryGroups = [ "media" ];
      optionals.features.nginx.proxyServices.kavita = 5030;
      services.kavita = {
        enable = true;
        settings = {
          Port = 3034;
        };
        tokenKeyFile = config.sops.secrets."kavita/token".path;
      };

    })
  ];
}
