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
  options.features.steam.enable = lib.mkEnableOption "Steam + Proton GE";
  config = lib.mkIf cfg.enable {
    features.preservation.persistDirs.home = [ ".steam" ];
    boot.kernelModules = [ "ntsync" ];
    programs = {
      gamemode.enable = true;
      steam = {
        enable = true;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
      };
    };
  };
}
