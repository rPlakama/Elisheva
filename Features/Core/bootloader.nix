{
  config,
  lib,
  ...
}:
let
  cfg = config.features.bootloader;
  headless = config.core.headless;
in
{
  options.features.bootloader = {

    enable = lib.mkOption "We both know that we need that.";

    plymouth = {
      enable = lib.mkEnableOption "Plymouth cool boot";
    };

  };

  config = lib.mkIf cfg.enable {

    systemd.services.NetworkManager-wait-online.enable = false;

    boot = {
      loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot.enable = true;
        timeout = 0;
      };
      plymouth = lib.mkIf cfg.plymouth.enable {
        enable = !headless;
        theme = "bgrt";
      };
      kernelParams = lib.mkIf cfg.plymouth.enable [
        "quiet"
        "splash"
        "udev.log_level=3"
      ];
      initrd.systemd.enable = true;
    };
  };
}
