{
  lib,
  config,
  pkgs,
  ...
}:
let
  featureCall = config.features;
  user = config.core.user;
  hasContainers = featureCall.virtualization.containers != { };
in
{
  options.features.virtualization = {
    enable = lib.mkEnableOption "Virtualization (libvirtd + Podman)";

    containers = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "OCI containers managed by Podman (schema matches virtualisation.oci-containers.containers); declaring any container enables Podman automatically";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (featureCall.virtualization.enable || hasContainers) {
      features.preservation.system.directories = [ "/var/lib/containers" ];

      environment.systemPackages = with pkgs; [
        podman-compose
      ];

      users.users.${user} = {
        group = user;
        extraGroups = [ "podman" ];
      };

      virtualisation = {
        containers.enable = true;

        podman = {
          enable = true;
          dockerCompat = true;
          autoPrune.enable = true;
          defaultNetwork.settings.dns_enabled = true;
        };

        oci-containers = {
          backend = "podman";
          containers = featureCall.virtualization.containers;
        };
      };
    })

    (lib.mkIf featureCall.virtualization.enable {
      features.preservation.system.directories = [ "/var/lib/libvirt" ];
      virtualisation.libvirtd.enable = true;
    })
  ];
}
