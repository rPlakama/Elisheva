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
  gsrEnable = config.features.gaming.gsr.enable;
in
{
  imports = [ inputs.gsr-ui-nix.nixosModules.default ];

  options.features.gaming = {
    enable = lib.mkEnableOption "Enable gaming bundle";

    steam.enable = lib.mkEnableOption "Enable Steam";
    gamescope.enable = lib.mkEnableOption "Enable Gamescope";
    gamemode.enable = lib.mkEnableOption "Enable Gamemode";
    gsr.enable = lib.mkEnableOption "Enable GPU Screen Recorder";

  };

  config = lib.mkIf cfg.enable {

    features.preservation.home.directories = [
      ".steam"
      "Games"
    ];

    boot.kernelModules = [ "ntsync" ];

    environment.systemPackages = with pkgs; [
      mangohud
    ];

    programs = {

      gamemode.enable = true;
      gamescope.enable = true;

      gpu-screen-recorder = {
        package = gsrPkg;
        enable = gsrEnable;
        ui.enable = true;
      };

      steam = {
        enable = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
      };
    };
  };
}
