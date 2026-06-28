{
  lib,
  config,
  ...
}: let
  cfg = config.features.virtualization;
  user = config.core.user;
  isNvidia = config.core.gpu.nvidia;
in {
  options.features.virtualization.enable = lib.mkEnableOption "Virtualization (libvirtd + Docker)";

  config = lib.mkIf cfg.enable {
    features.preservation.system.directories = [
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
