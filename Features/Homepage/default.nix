{
  config,
  lib,
  ...
}:
let
  cfg = config.optionals.features.homepage;
  currentIP = config.core.ip;
  nginxCfg = config.optionals.features.nginx;
  domain = config.core.domain;
in
{
  options.optionals.features.homepage = {
    enable = lib.mkOption {
      type = lib.types.bool;
      description = "Homepage dashboard";
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {

    optionals.features.nginx.proxyServices.dashboard = 8082;

    services.homepage-dashboard = {
      enable = true;
      listenPort = 8082;
      allowedHosts = "dashboard.${domain},${currentIP},${currentIP}:8082";

      settings = {
        title = "Moontier Dashboard";
        background = "https://w.wallhaven.cc/full/8g/wallhaven-8gdpgo.png";
        cardBlur = "md";
      };

      services = [
        {
          "General" = lib.mapAttrsToList (name: port: {
            "${name}" = {
              icon = "si-${name}";
              href = "https://${name}.${domain}";
              description = "Auto-generated link for ${name}";
            };
          }) nginxCfg.proxyServices;
        }
      ];
    };
  };
}
