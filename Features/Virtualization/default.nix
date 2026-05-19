{ lib, config, ... }:
let
  cfg = config.optionals.features.virtualization;
  isNvidia = config.optionals.features.nvidia.enable;
in
{
  options.optionals.features.virtualization.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Virtualization";
    default = false;
  };

  config = lib.mkIf cfg.enable {
    virtualisation = {
      libvirtd.enable = true;
      docker = {
        enable = true;
        enableNvidia = isNvidia;
        enableOnBoot = false;
        autoPrune.enable = true;
      };
    };
  };
}
