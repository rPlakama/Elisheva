{
  lib,
  config,
  ...
}: let
  featureCall = config.features;
  user = config.core.user;
  isLaptop = config.core.isLaptop.enable;
in {
  options.features.virtualization.enable = lib.mkEnableOption "Virtualization (libvirtd + Docker)";

  config = lib.mkIf featureCall.virtualization.enable {
    features.preservation.system.directories = [
      "/var/lib/docker"
      "/var/lib/libvirt"
    ];

    users.users.${user} = {
      group = user;
      extraGroups = [
        "docker"
      ];
    };

    virtualisation = {
      libvirtd.enable = true;
      docker = {
        enable = true;
        enableOnBoot = !isLaptop;
        autoPrune.enable = true;
      };
    };
  };
}
