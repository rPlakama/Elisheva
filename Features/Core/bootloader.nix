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
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Bootloader Configuration";
    };
    plymouth.enable = lib.mkOption {
      type = lib.types.bool;
      default = !headless;
      description = "Plymouth boot splash";
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
        enable = true;
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
