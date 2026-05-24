{ config, lib, ... }:

let
  cfg = config.features.rrstack;

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
  options.features.rrstack.enable = lib.mkEnableOption "*-rr stack (Sonarr, Radarr, Jackett, Prowlarr)";

  config = lib.mkIf cfg.enable {
    features = {
      mediaPermissions.enable = true;
      preservation.persistDirs.system = [
        "/var/lib/jackett"
        "/var/lib/sonarr"
        "/var/lib/radarr"
        "/var/lib/prowlarr"
      ];
      unifiedDNS.proxyServices = mediaServicesWithPermissions // mediaNonPermissions;
    };
    services =
      (lib.mapAttrs (name: port: {
        enable = true;
        group = "media";
      }) mediaServicesWithPermissions)
      // (lib.mapAttrs (name: port: {
        enable = true;
      }) mediaNonPermissions);
  };
}
