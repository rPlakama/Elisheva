{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.optionals.features.kavita;
  domain = "moontier.online";
  currentIP = "192.168.1.106";
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
      services.kavita = {
        enable = true;
        package = pkgs-kavita.kavita;
        tokenKeyFile = config.sops.secrets."kavita/token".path;
        settings = {
          BaseUrl = "/kavita/";
          Port = 3034;
        };
      };
      services.nginx = {
        additionalModules = [ pkgs.nginxModules.subsFilter ];
        virtualHosts."${domain}".locations = {
          "^~ /kavita/" = {
            proxyPass = "http://${currentIP}:3034";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header Accept-Encoding "";
              sub_filter '<base href="/">' '<base href="/kavita/">';
              sub_filter_once on;
              sub_filter_types text/html;
            '';
          };
          "^~ /kavita/api" = {
            proxyPass = "http://${currentIP}:3034";
            proxyWebsockets = true;
          };
        };
      };
    })
  ];
}
