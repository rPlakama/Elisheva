{
  config,
  lib,
  ...
}: let
  featureCall = config.features;
in {
  options.features.gnomeDesktop.enable = lib.mkEnableOption "GNOME desktop";

  config = lib.mkIf featureCall.gnomeDesktop.enable {
    services.xserver.enable = true;
    services.desktopManager.gnome.enable = true;
  };
}
