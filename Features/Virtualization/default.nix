{ lib, config, ... }:
let
  cfg = config.features.virtualization;
  isNvidia = config.features.nvidia.enable;
  user = config.core.user;
in
{
  options.features.virtualization.enable = lib.mkEnableOption "Virtualization (libvirtd + Docker)";

  config = lib.mkIf cfg.enable {
    features.preservation.persistDirs.system = [
      "/var/lib/docker"
      "/var/lib/libvirt"
    ];

    users.users.${user} = {
      group = user;
      extraGroups = [
        "docker"
        "wheel"
        "video"
        "audio"
      ];
    };

    virtualisation = {
      libvirtd.enable = true;
      docker = {
        enable = true;
        enableNvidia = isNvidia;
        enableOnBoot = true;
        autoPrune.enable = true;
      };
    };
  };
}
