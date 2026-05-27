{
  config,
  lib,
  ...
}:

let
  cfg = config.features.bootloader;
  nixosInit = config.features.bootloader.nixos-init.enable;
in

{
  options.features.bootloader.nixos-init.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "nixos-init";
  };

  options.features.bootloader.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Bootloader Configuration";
  };
  config = lib.mkIf cfg.enable {
    services.userborn.enable = nixosInit;
    system = {
      etc.overlay.enable = nixosInit;
      nixos-init.enable = nixosInit;
    };
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
