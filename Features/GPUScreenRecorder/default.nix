{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.gpuScreenRecorder;
in

{
  imports = [
    inputs.gsr-ui-nix.nixosModules.default
  ];

  options.features.gpuScreenRecorder.enable = lib.mkEnableOption "GPU Screen Recorder replay buffer";

  config = lib.mkIf cfg.enable {
    programs.gpu-screen-recorder = {
      package = inputs.gsr-ui-nix.packages.${pkgs.stdenv.hostPlatform.system}.gpu-screen-recorder;
      enable = true;
      ui.enable = true;
    };
  };
}
