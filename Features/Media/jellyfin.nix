{ config, lib, ... }:
let
  cfg = config.features.jellyfin;
in
{
  options.features.jellyfin.enable = lib.mkEnableOption "Jellyfin media server";
  config = lib.mkIf cfg.enable {
    features = {
      mediaPermissions.enable = true;
      preservation.system.directories = [ "/var/lib/jellyfin" ];
      unifiedDNS.proxyServices.jellyfin = 8096;
    };
    services.jellyfin = {
      enable = true;
      group = "media";
      openFirewall = true;
    };
    users.users.jellyfin.extraGroups = [
      "video"
      "render"
    ];
  };
}
