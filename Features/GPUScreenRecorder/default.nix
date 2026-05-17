{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.gsr-ui-nix.nixosModules.default
  ];

  options.optionals.features.gpuScreenRecorder.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "GPU Screen Recorder Replay Buffer";
  };

  config = lib.mkIf config.optionals.features.gpuScreenRecorder.enable {
    programs.gpu-screen-recorder = {
      package = inputs.gsr-ui-nix.packages.${pkgs.stdenv.hostPlatform.system}.gpu-screen-recorder;
      enable = true;
      ui.enable = true;
    };
  };
}
