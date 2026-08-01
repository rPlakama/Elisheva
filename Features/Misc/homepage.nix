{
  config,
  lib,
  ...
}:
let
  cfg = config.features.homepage;
  currentIP = config.core.ip;
  dnsCfg = config.features.unifiedDNS;
  domain = config.core.domain;
  host = config.core.host;
  meta = svc: if builtins.isInt svc then { } else svc;
in
{
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
      allowedHosts = lib.concatStringsSep "," (
        [ "dashboard.${domain}" ]
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
          "General" = lib.mapAttrsToList (name: svc: {
            "${name}" = {
              icon = (meta svc).icon or "si-${name}";
              href = "https://${name}.${domain}";
              description = (meta svc).description or "Auto-generated link for ${name}";
            };
          }) dnsCfg.proxyServices;
        }
      ];
    };
  };
}
