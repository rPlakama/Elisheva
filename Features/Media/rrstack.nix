{
  config,
  lib,
  pkgs,
  ...
}:
let
  featureCall = config.features;

  mediaServicesWithPermissions = {
    jackett = {
      port = 9117;
      icon = "sh-jackett";
      description = "Torrent indexer aggregator";
    };
    sonarr = {
      port = 8989;
      icon = "si-sonarr";
      description = "TV series management";
    };
    radarr = {
      port = 7878;
      icon = "si-radarr";
      description = "Movie management";
    };
    lidarr = {
      port = 8686;
      icon = "sh-lidarr";
      description = "Music management";
    };
  };

  mediaNonPermissions = {
    prowlarr = {
      port = 9696;
      icon = "sh-prowlarr";
      description = "Indexer manager";
    };
    flaresolverr = {
      port = 8191;
      icon = "sh-flaresolverr";
      description = "Cloudflare-bypass proxy for indexers";
    };
  };
in
{
  options.features.rrstack.enable = lib.mkEnableOption "*-rr stack (Sonarr, Radarr, Jackett, Prowlarr)";

  config = lib.mkIf featureCall.rrstack.enable {
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
