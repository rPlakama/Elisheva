{
  config,
  lib,
  ...
}: let
  featureCall = config.features;
in {
  options.features.jellyfin.enable = lib.mkEnableOption "Jellyfin media server";

  config = lib.mkIf featureCall.jellyfin.enable {
    features = {
      mediaPermissions.enable = true;
      preservation.system.directories = ["/var/lib/jellyfin"];
      unifiedDNS.proxyServices.jellyfin = {
        port = 8096;
        icon = "si-jellyfin";
        description = "Movies, shows and music";
      };
    };
    services.jellyfin = {
      enable = true;
      group = "media";
    };
    users.users.jellyfin.extraGroups = [
      "video"
      "render"
    ];
  };
}
