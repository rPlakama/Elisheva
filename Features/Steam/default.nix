{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.steam;
in

{
  features.preservation.persistDirs.system = [ ".steam" ];
  options.features.steam.enable = lib.mkEnableOption "Steam + Proton GE";
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
