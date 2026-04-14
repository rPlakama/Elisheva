{ config, lib, ... }:

let
  cfg = config.optionals.features.rrstack;

  mediaServicesWithPermissions = [
    "jackett"
    "jellyfin"
    "bazarr"
    "sonarr"
    "radarr"
    "readarr"
  ];

  mediaNonPermissions = [
    "prowlarr"
    "flaresolverr"
  ];
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

    services = (
      lib.genAttrs mediaServicesWithPermissions (name: {
        enable = true;
        openFirewall = true;
        group = "media";
      })
      // lib.genAttrs mediaNonPermissions (name: {
        enable = true;
        openFirewall = true;
      })
    );
  };
}
