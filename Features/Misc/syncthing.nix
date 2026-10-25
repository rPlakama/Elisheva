{
  config,
  lib,
  ...
}:
let
  featureCall = config.features;
  user = config.core.user;
  headless = config.core.headless;
  guiPort = 8384;
  serverDataDir = "/var/lib/syncthing";
in
{
  options.features.syncthing = {
    enable = lib.mkEnableOption "Syncthing";
  };

  config = lib.mkIf featureCall.syncthing.enable (
    lib.mkMerge [
      {
        services.syncthing = {
          enable = true;
          user = lib.mkDefault user;
          group = lib.mkDefault user;
          dataDir = lib.mkDefault "/home/${user}";
          guiAddress = "127.0.0.1:${toString guiPort}";
          openDefaultPorts = true;
        };
      }
      (lib.mkIf headless {
        services.syncthing = {
          user = "syncthing";
          group = "syncthing";
          dataDir = serverDataDir;
          settings.gui.insecureSkipHostcheck = true;
        };

        features = {
          preservation.system.directories = [ serverDataDir ];
          unifiedDNS.proxyServices.syncthing = {
            port = guiPort;
            icon = "si-syncthing";
            description = "Continuous file synchronization";
          };
        };
      })
    ]
  );
}
