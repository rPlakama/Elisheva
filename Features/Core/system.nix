{
  config,
  lib,
  ...
}: let
  cfg = config.features.core;
  user = config.core.user;
in {
  config = lib.mkIf cfg.enable {
    security.sudo-rs.enable = true;

    networking = {
      networkmanager.enable = true;
      wireless.enable = true;
    };

    users.users.${user} = {
      group = user;
      extraGroups = ["networkmanager"];
    };

    programs = {
      fish = {
        enable = true;
        generateCompletions = true;
      };
      zoxide = {
        enable = true;
        enableFishIntegration = true;
      };
    };
    documentation = {
      dev.enable = true;
      man.enable = true;
    };
    hardware = {
      enableAllFirmware = true;
      enableRedistributableFirmware = true;
    };
  };
}
