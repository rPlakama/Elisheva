{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  featureCall = config.features;
  user = config.core.user;
  gsrPkg = inputs.gsr-ui-nix.packages.${pkgs.stdenv.hostPlatform.system}.gpu-screen-recorder;
  gsrEnable = featureCall.gaming.gsr.enable;

  triforce = pkgs.callPackage ../../pkgs/triforce.nix { };
in
{
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
    triforce.enable = lib.mkEnableOption "Triforce (native Ocarina of Time recomp)";
  };

  config = lib.mkIf featureCall.gaming.enable {
    features.preservation.home.directories = [
      ".steam"
      "Games"
    ];

    boot.kernelModules = [ "ntsync" ];

    hjem.users.${user}.packages =
      with pkgs;
      [
        mangohud
        lutris
        low-latency-layer
      ]
      ++ lib.optionals featureCall.gaming.triforce.enable [ triforce ];

    programs = {
      gamemode.enable = featureCall.gaming.gamemode;
      gamescope.enable = featureCall.gaming.gamescope;

      gpu-screen-recorder = {
        package = gsrPkg;
        enable = gsrEnable;
        ui.enable = true;
      };

      steam = lib.mkIf featureCall.gaming.steam {
        enable = true;
        remotePlay.openFirewall = true;
        gamescopeSession.enable = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;

        extraCompatPackages = with pkgs; [
          proton-cachyos
          proton-ge-custom
        ];
      };
    };
  };
}
