{
  config,
  lib,
  ...
}:

let
  cfg = config.optionals.features.bootloader;
in

{
  options.optionals.features.bootloader.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Bootloader Configuration";
    default = false;
  };
  config = lib.mkIf cfg.enable {
    systemd.services.NetworkManager-wait-online.enable = false;
    boot = {
      plymouth = {
        enable = true;
        theme = "spinner";
      };

      loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot.enable = true;
        timeout = 0;
      };
    };
  };
}