{
  config,
  lib,
  ...
}:
let
  cfg = config.features.core;
in
{
  config = lib.mkIf cfg.enable {
    security.sudo-rs.enable = true;
    networking.networkmanager.enable = true;
    networking.wireless.enable = true;

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
