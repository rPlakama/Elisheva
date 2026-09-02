{
  config,
  lib,
  ...
}:
let
  featureCall = config.features;
in
{
  options.features.tdarr.enable = lib.mkEnableOption "Tdarr Service";

  config = lib.mkIf featureCall.tdarr.enable {
    features = {

      mediaPermissions.enable = true;
      preservation.system.directories = [ "/var/lib/tdarr" ];

      unifiedDNS.proxyServices.tdarr = {
        port = 8096;
        icon = "si-tdarr";
        description = "Movies, shows and music";
      };
    };
    services.tdarr = {
      enable = true;
      group = "media";
    };
    users.users.tdarr.extraGroups = [
      "video"
      "render"
    ];
  };
}
