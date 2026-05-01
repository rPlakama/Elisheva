{ lib, config, ... }:

let
  cfg = config.optionals.features.kavita;
in
{
  options.optionals.features.kavita.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Kavita, a ebook/comic client";
    default = false;
  };

  config = lib.mkMerge [
    {
      sops = {
        secrets = {
          "kavita/token" = { };
        };
      };
    }

    (lib.mkIf cfg.enable {
      core.features.mediaPermissions.enable = true;
      optionals.features.nginx.proxyServices.kavita = 3034;
      systemd.services.kavita.serviceConfig.SupplementaryGroups = [ "media" ];
      services.kavita = {
        enable = true;
        port = 3034;
        settings = {
          baseUrl = "/kavita/";
        };
        tokenKeyFile = config.sops.secrets."kavita/token".path;
      };
    })
  ];
}
