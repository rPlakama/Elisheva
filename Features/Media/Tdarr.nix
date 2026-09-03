{
  config,
  lib,
  ...
}:
let
  featureCall = config.features;
  serverPort = 8226;
in
{
  options.features.tdarr.enable = lib.mkEnableOption "Tdarr Service";

  config = lib.mkIf featureCall.tdarr.enable {
    features = {

      mediaPermissions.enable = true;
      preservation.system.directories = [ "/var/lib/tdarr" ];

      unifiedDNS.proxyServices.tdarr = {
        port = serverPort;
        icon = "si-tdarr";
        description = "Movies, shows and music";
      };
    };
    services.tdarr = {
      enable = true;
      group = "media";
      server.serverPort = serverPort;
    };
    systemd.services.tdarr-server.serviceConfig.StateDirectory = "tdarr/server";

    users.users.tdarr.extraGroups = [
      "video"
      "render"
    ];
  };
}
