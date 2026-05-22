{ lib, config, ... }:
let
  cfg = config.optionals.features.virtualization;
  isNvidia = config.core.features.nvidia.enable;
  persistEnabled = config.optionals.features.preservation.enable;
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

    optionals.features.preservation.keepDirs.additionalDirs = lib.mkIf persistEnabled [
      "/var/lib/docker"
    ];
  };
}
