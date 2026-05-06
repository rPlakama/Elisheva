{ config, lib, ... }:

let
  cfg = config.optionals.features.rrstack;

  mediaServicesWithPermissions = {
    jackett = 9117;
    jellyfin = 8096;
    sonarr = 8989;
    radarr = 7878;
    readarr = 8787;
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
    users.users.jellyfin.extraGroups = [
      "video"
      "render"
    ];

    services =
      (lib.mapAttrs (name: port: {
        enable = true;
        openFirewall = true;
        group = "media";
      }) mediaServicesWithPermissions)
      // (lib.mapAttrs (name: port: {
        enable = true;
        openFirewall = true;
      }) mediaNonPermissions);
    optionals.features.nginx.proxyServices = mediaServicesWithPermissions // mediaNonPermissions;
  };
}
