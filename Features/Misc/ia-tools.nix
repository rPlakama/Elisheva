{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) optionals;
  featureCall = config.features;
  user = config.core.user;
  gpu = config.core.gpu;
in {
  options.features.ia-tools.enable = lib.mkEnableOption "General IA Tools";

  config = lib.mkIf featureCall.ia-tools.enable {
    features = {
      preservation.home.directories = [
        ".ollama"
      ];
    };
    hjem.users.${user}.packages = with pkgs;
      [opencode] ++ optionals gpu.nvidia [ollama-cuda] ++ optionals gpu.amd [ollama-rocm];
  };
}
