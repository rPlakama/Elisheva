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
    features.preservation.home.directories = [
      ".steam"
      "Games"
    ];
    boot.kernelModules = [ "ntsync" ];

    environment.systemPackages = with pkgs; [
      bottles
    ];

    programs = {
      gamemode.enable = true;
      gamescope.enable = true;
      steam = {
        enable = true;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
      };
    };
  };
}
