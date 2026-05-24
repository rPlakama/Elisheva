{
  config,
  lib,
  ...
}:

let
  cfg = config.features.bootloader;
in

{
  options.features.bootloader.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Bootloader Configuration";
  };
  config = lib.mkIf cfg.enable {
    systemd.services.NetworkManager-wait-online.enable = false;
    boot = {
      plymouth = {
        enable = true;
        theme = "bgrt";
      };

      loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot.enable = true;
        timeout = 0;
      };
    };
  };
}