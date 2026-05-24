{ lib, config, ... }:
let
  cfg = config.features.virtualization;
  isNvidia = config.features.nvidia.enable;
in
{
  options.features.virtualization.enable = lib.mkEnableOption "Virtualization (libvirtd + Docker)";

  config = lib.mkIf cfg.enable {
    features.preservation.persistDirs.system = [
      "/var/lib/docker"
      "/var/lib/libvirt"
    ];

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
