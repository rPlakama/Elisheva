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

    hardware.uinput.enable = true;

    services.sunshine = {
      enable = true;
      openFirewall = true;
      autoStart = true;
      capSysAdmin = true;
    };
  };
}
