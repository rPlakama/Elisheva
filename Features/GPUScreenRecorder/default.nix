{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.optionals.features.gpuScreenRecorder;
in

{
  imports = [
    inputs.gsr-ui-nix.nixosModules.default
  ];

  options.optionals.features.gpuScreenRecorder.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "GPU Screen Recorder Replay Buffer";
  };

  config = lib.mkIf cfg.enable {
    programs.gpu-screen-recorder = {
      package = inputs.gsr-ui-nix.packages.${pkgs.stdenv.hostPlatform.system}.gpu-screen-recorder;
      enable = true;
      ui.enable = true;
    };
  };
}