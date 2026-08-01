{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.rrstack;

  mediaServicesWithPermissions = {
    jackett = {
      port = 9117;
      icon = "si-jackett";
    };
    sonarr = {
      port = 8989;
      icon = "si-sonarr";
    };
    radarr = {
      port = 7878;
      icon = "si-radarr";
    };
    lidarr = {
      port = 8686;
      icon = "si-lidarr";
    };
  };

  mediaNonPermissions = {
    prowlarr = {
      port = 9696;
      icon = "si-prowlarr";
    };
    flaresolverr = { port = 8191; };
  };
in
{
  options.features.rrstack.enable = lib.mkEnableOption "*-rr stack (Sonarr, Radarr, Jackett, Prowlarr)";

  config = lib.mkIf cfg.enable {
    features = {
      mediaPermissions.enable = true;
      preservation.system.directories = [
        "/var/lib/jackett"
        "/var/lib/sonarr"
        "/var/lib/radarr"
        "/var/lib/lidarr"
        "/var/lib/prowlarr"
      ];
      unifiedDNS.proxyServices = mediaServicesWithPermissions // mediaNonPermissions;
    };
    services =
      (lib.mapAttrs (name: svc: {
        enable = true;
        group = "media";
      }) mediaServicesWithPermissions)
      // (lib.mapAttrs (name: svc: {
        enable = true;
      }) mediaNonPermissions);

    systemd.services.lidarr.path = [ pkgs.ffmpeg-full ];
  };
}
