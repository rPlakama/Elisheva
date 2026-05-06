{
  config,
  lib,
  ...
}:
let
  cfg = config.optionals.features.nginx;
  domain = "moontier.online";
in
{
  options.optionals.features.nginx = {
    enable = lib.mkOption {
      type = lib.types.bool;
      description = "Nginx with Let's Encrypt via Hetzner DNS-01";
      default = false;
    };

    config = lib.mkIf cfg.enable {
      services.homepage-dashboard = {
        enable = true;
        services = [
          {
            "Media" = lib.mapAttrsToList (name: port: {
              "${name}" = {
                href = "https://${name}.${domain}";
              };
            }) cfg.proxyServices;
          }
        ];
      };
    };
  };
}
