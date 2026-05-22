{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.optionals.features.steam;
in

{
  options.optionals.features.steam.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Steam Configuration";
    default = false;
  };
  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "ntsync" ];
    programs.steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
  };
}