{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.features.kavita;
  pkgs-kavita = import inputs.kavita { inherit (pkgs) system; };
in
{
  options.features.kavita.enable = lib.mkEnableOption "Kavita reading server";
  config = lib.mkMerge [
    {
      sops.secrets."kavita/token" = { };
    }
    (lib.mkIf cfg.enable {
      features.mediaPermissions.enable = true;
      networking.firewall.allowedTCPPorts = [ 3034 ];

      systemd.services.kavita.serviceConfig.SupplementaryGroups = [ "media" ];
      features.unifiedDNS.proxyServices.kavita = 3034;

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
