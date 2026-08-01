{
  config,
  lib,
  ...
}:
let
  cfg = config.features.jellyfin;
in
{
  options.features.jellyfin.enable = lib.mkEnableOption "Jellyfin media server";

  config = lib.mkIf cfg.enable {
    features = {
      mediaPermissions.enable = true;
      preservation.system.directories = [ "/var/lib/jellyfin" ];
      unifiedDNS.proxyServices.jellyfin = {
        port = 8096;
        icon = "si-jellyfin";
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
