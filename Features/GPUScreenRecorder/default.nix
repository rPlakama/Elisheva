{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.gpu-screen-recorder-ui-nix.nixosModules.default
  ];

  options.optionals.features.gpuScreenRecorder.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "GPU Screen Recorder Replay Buffer";
  };

  config = lib.mkIf config.optionals.features.gpuScreenRecorder.enable {
    programs.gpu-screen-recorder.enable = true;
    environment.systemPackages = [
      inputs.gpu-screen-recorder-ui-nix.packages.${pkgs.system}.default
    ];
  };
}
