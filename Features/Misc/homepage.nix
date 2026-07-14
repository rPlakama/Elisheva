{
  config,
  lib,
  ...
}: let
  cfg = config.features.homepage;
  currentIP = config.core.ip;
  dnsCfg = config.features.unifiedDNS;
  domain = config.core.domain;
in {
  options.features.homepage = {
    enable = lib.mkEnableOption "Homepage dashboard";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.features.unifiedDNS.enable;
        message = "Homepage requires unifiedDNS";
      }
    ];

    features.unifiedDNS.proxyServices.dashboard = 8082;

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
          "General" =
            lib.mapAttrsToList (name: port: {
              "${name}" = {
                icon = "si-${name}";
                href = "https://${name}.${domain}";
                description = "Auto-generated link for ${name}";
              };
            })
            dnsCfg.proxyServices;
        }
      ];
    };
  };
}
