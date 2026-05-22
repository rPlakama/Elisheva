{ config, lib, ... }:
let
  cfg = config.optionals.features.jellyfin;
  persistEnabled = config.optionals.features.preservation.enable;
in
{
  options.optionals.features.jellyfin.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Jellyfin is an... media server thingy";
    default = false;
  };
  config = lib.mkIf cfg.enable {
    core.features.mediaPermissions.enable = true;
    optionals.features.unifiedDNS.proxyServices.jellyfin = 8096;
    services.jellyfin = {
      enable = true;
      group = "media";
      openFirewall = true;
    };
    users.users.jellyfin.extraGroups = [
      "video"
      "render"
    ];

    optionals.features.preservation.keepDirs.additionalDirs = lib.mkIf persistEnabled [
      "/var/lib/jellyfin"
    ];
  };
}