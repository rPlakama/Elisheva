{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:

let
  cfg = config.features.gaming;
in

{
  imports = [
    inputs.gsr-ui-nix.nixosModules.default
  ];

  options.features.gaming = {
    enable = lib.mkEnableOption "Enable gaming bundle";
    steam.enable = lib.mkEnableOption "Steam + Proton GE";
    gamescope.enable = lib.mkEnableOption "Gamescope";
    gamemode.enable = lib.mkEnableOption "Gamemode";
    gsr.enable = lib.mkEnableOption "GSR-UI overlay";
  };

  config = lib.mkIf cfg.enable {
    features.gaming = {
      steam.enable = lib.mkDefault true;
      gamescope.enable = lib.mkDefault true;
      gamemode.enable = lib.mkDefault true;
      gsr.enable = lib.mkDefault false;
    };

    features.preservation.home.directories = [
      ".steam"
      "Games"
    ];
    boot.kernelModules = [ "ntsync" ];

    environment.systemPackages = with pkgs; [
      bottles
    ];

    programs = {
      gamemode.enable = cfg.gamemode.enable;
      gamescope.enable = cfg.gamescope.enable;
      gpu-screen-recorder = {
        package = inputs.gsr-ui-nix.packages.${pkgs.stdenv.hostPlatform.system}.gpu-screen-recorder;
        enable = cfg.gsr.enable;
        ui.enable = true;
      };
      steam = {
        enable = cfg.steam.enable;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
      };
    };
  };
}
