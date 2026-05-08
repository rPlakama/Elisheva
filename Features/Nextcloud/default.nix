{
  config,
  lib,
  ...
}:
let
  cfg = config.optionals.features.nextcloud;
in
{
  options.optionals.features.nextcloud.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Nextcloud Storage Solution";
    default = false;
  };

  config = {
    sops.secrets."nextcloud/admin" = lib.mkIf cfg.enable {
      owner = "nextcloud";
      group = "nextcloud";
    };

    optionals.features.unifiedDNS.proxyServices.nextcloud = lib.mkIf cfg.enable 8080;

    services.nextcloud = lib.mkIf cfg.enable {
      enable = true;
      hostName = "nextcloud.moontier";
      config = {
        dbtype = "sqlite";
        adminpassFile = config.sops.secrets."nextcloud/admin".path;
      };
    };
  };
}
