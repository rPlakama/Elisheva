{
  config,
  lib,
  ...
}: let
  featureCall = config.features;
in {
  options.features.sunshine.enable = lib.mkEnableOption "Sunshine game streaming";
  config = lib.mkIf featureCall.sunshine.enable {
    features.preservation.system.directories = ["/var/lib/sunshine"];

    services.sunshine = {
      enable = true;
      openFirewall = true;
      autoStart = true;
    };
  };
}
