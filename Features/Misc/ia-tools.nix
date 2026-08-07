{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) optionals;
  cfg = config.features.ia-tools;
  gpu = config.core.gpu;
in
{

  options.features.ia-tools.enable = lib.mkEnableOption "General IA Tools";

  config = lib.mkIf cfg.enable {
    features = {
      preservation.home.directories = [
        ".ollama"
      ];
    };
    hjem.users.${config.core.user}.packages =
      with pkgs;
      [ opencode ] ++ optionals gpu.nvidia [ ollama-cuda ] ++ optionals gpu.amd [ ollama-rocm ];
  };
}
