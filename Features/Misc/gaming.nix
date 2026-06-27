{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.features.gaming;
  gsrPkg = inputs.gsr-ui-nix.packages.${pkgs.system}.gpu-screen-recorder;
in
{
  imports = [ inputs.gsr-ui-nix.nixosModules.default ];

  options.features.gaming = {
    enable = lib.mkEnableOption "Enable gaming bundle";
    steam.enable = lib.mkEnableOption "Steam + Proton GE" // {
      default = true;
    };
    gamescope.enable = lib.mkEnableOption "Gamescope" // {
      default = true;
    };
    gamemode.enable = lib.mkEnableOption "Gamemode" // {
      default = true;
    };
    gsr.enable = lib.mkEnableOption "GSR-UI overlay";
  };

  config = lib.mkIf cfg.enable {
    features.preservation.home.directories = [
      ".steam"
      "Games"
    ];

    boot.kernelModules = [ "ntsync" ];

    environment.systemPackages = with pkgs; [
      mangohud
      bottles
    ];

    programs = {
      gamemode.enable = cfg.gamemode.enable;
      gamescope.enable = cfg.gamescope.enable;
      gpu-screen-recorder = {
        package = gsrPkg;
        enable = cfg.gsr.enable;
        ui.enable = cfg.gsr.enable;
      };
      steam = {
        enable = cfg.steam.enable;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
      };
    };
  };
}
