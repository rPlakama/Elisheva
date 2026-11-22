{
  config,
  lib,
  ...
}: let
  featureCall = config.features;
in {
  options.features.kdeDesktop.enable = lib.mkEnableOption "KDE Plasma 6 desktop";

  config = lib.mkIf featureCall.kdeDesktop.enable {
    services.xserver.enable = true;
    services.desktopManager.plasma6.enable = true;
  };
}
