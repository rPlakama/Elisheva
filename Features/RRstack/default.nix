{ config, lib, ... }:

let
  cfg = config.optionals.features.rrstack;

  mediaServicesWithPermissions = {
    jackett = 9117;
    sonarr = 8989;
    radarr = 7878;
  };

  mediaNonPermissions = {
    prowlarr = 9696;
    flaresolverr = 8191;
  };
in
{
  options.optionals.features.rrstack.enable = lib.mkOption {
    type = lib.types.bool;
    description = "*-rr stack, with media-group permissions.";
    default = false;
  };

  config = lib.mkIf cfg.enable {
    core.features.mediaPermissions.enable = true;
    services =
      (lib.mapAttrs (name: port: {
        enable = true;
        group = "media";
      }) mediaServicesWithPermissions)
      // (lib.mapAttrs (name: port: {
        enable = true;
      }) mediaNonPermissions);

    optionals.features.unifiedDNS.proxyServices = mediaServicesWithPermissions // mediaNonPermissions;
  };
}
