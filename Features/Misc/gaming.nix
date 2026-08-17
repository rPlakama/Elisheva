{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.features.gaming;
  user = config.core.user;
  gsrPkg = inputs.gsr-ui-nix.packages.${pkgs.stdenv.hostPlatform.system}.gpu-screen-recorder;
  gsrEnable = config.features.gaming.gsr.enable;
in
{
  imports = [ inputs.gsr-ui-nix.nixosModules.default ];

  options.features.gaming = {
    enable = lib.mkEnableOption "Enable gaming bundle";

    steam = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Steam (part of the bundle, can be opted out)";
    };
    gamescope = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Gamescope (part of the bundle, can be opted out)";
    };
    gamemode = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Gamemode (part of the bundle, can be opted out)";
    };
    gsr.enable = lib.mkEnableOption "Enable GPU Screen Recorder";
  };

  config = lib.mkIf cfg.enable {

    features.preservation.home.directories = [
      ".steam"
      "Games"
    ];

    boot.kernelModules = [ "ntsync" ];

    hjem.users.${user}.packages = with pkgs; [
      mangohud
      lutris
    ];

    programs = {

      gamemode.enable = cfg.gamemode;
      gamescope.enable = cfg.gamescope;

      gpu-screen-recorder = {
        package = gsrPkg;
        enable = gsrEnable;
        ui.enable = true;
      };

      steam = lib.mkIf cfg.steam {
        enable = true;
        extraCompatPackages = with pkgs; [
          proton-cachyos
          proton-ge-bin
        ];
      };
    };
  };
}
