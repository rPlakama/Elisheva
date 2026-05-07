{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.optionals.features.kavita;
  pkgs-kavita = import inputs.nixpkgs-kavita { inherit (pkgs) system; };
in
{
  options.optionals.features.kavita.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Kavita.";
    default = false;
  };
  config = lib.mkMerge [
    {
      sops.secrets."kavita/token" = { };
    }
    (lib.mkIf cfg.enable {
      core.features.mediaPermissions.enable = true;
      networking.firewall.allowedTCPPorts = [ 3034 ];

      systemd.services.kavita.serviceConfig.SupplementaryGroups = [ "media" ];
      optionals.features.unifiedDNS.proxyServices.kavita = 3034;

      services.kavita = {
        enable = true;
        package = pkgs-kavita.kavita;
        tokenKeyFile = config.sops.secrets."kavita/token".path;
        settings = {
          Port = 3034;
        };
      };
    })
  ];
}
