{
  config,
  lib,
  ...
}: let
  featureCall = config.features;
  currentIP = config.core.ip;
  dnsCfg = featureCall.unifiedDNS;
  domain = config.core.domain;
  host = config.core.host;
  meta = svc:
    if builtins.isInt svc
    then {}
    else svc;
in {
  options.features.homepage = {
    enable = lib.mkEnableOption "Homepage dashboard";
  };

  config = lib.mkIf featureCall.homepage.enable {
    assertions = [
      {
        assertion = featureCall.unifiedDNS.enable;
        message = "Homepage requires unifiedDNS";
      }
    ];

    features.unifiedDNS.proxyServices.dashboard = {
      port = 8082;
      icon = "sh-homepage";
      description = "Service dashboard";
    };

    services.homepage-dashboard = {
      enable = true;
      listenPort = 8082;
      allowedHosts = lib.concatStringsSep "," (
        ["dashboard.${domain}"]
        ++ lib.optionals (currentIP != "") [
          currentIP
          "${currentIP}:8082"
        ]
      );

      settings = {
        title = "${host} Dashboard";
        background = "https://w.wallhaven.cc/full/8g/wallhaven-8gdpgo.png";
        cardBlur = "md";
      };

      services = [
        {
          "General" =
            lib.mapAttrsToList (name: svc: {
              "${name}" = {
                icon = (meta svc).icon or "si-${name}";
                href = "https://${name}.${domain}";
                description = (meta svc).description or "Auto-generated link for ${name}";
              };
            })
            dnsCfg.proxyServices;
        }
      ];
    };
  };
}
