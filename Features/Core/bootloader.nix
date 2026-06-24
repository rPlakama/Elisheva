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
  options.features.bootloader = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Bootloader Configuration";
    };
    nixos-init.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "nixos-init";
    };
    plymouth.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Plymouth boot splash";
    };
  };

  config = lib.mkIf cfg.enable {
    services.userborn.enable = nixosInit;
    system = {
      etc.overlay.enable = nixosInit;
      nixos-init.enable = nixosInit;
    };
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
