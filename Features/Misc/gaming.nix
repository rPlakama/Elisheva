{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.features.gaming;
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
    emulation = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whatever enable game-emulation";
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

    environment.systemPackages =
      with pkgs;
      [
        mangohud
      ]
      ++ lib.optionals (cfg.emulation) [
        rpcs3
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
        extraCompatPackages = [ pkgs.proton-ge-bin ];
      };
    };
  };
}
