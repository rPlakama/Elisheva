{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  featureCall = config.features;
  user = config.core.user;
  gpu = config.core.gpu;
  ollamaPkg =
    if gpu.nvidia then
      pkgs.ollama-cuda
    else if gpu.amd then
      pkgs.ollama-rocm
    else
      pkgs.ollama;
in
{
  options.features.ia-tools.enable = lib.mkEnableOption "General IA Tools";

  config = lib.mkIf featureCall.ia-tools.enable {

    environment.systemPackages = [ ollamaPkg ];

    hjem.users.${user}.packages = (
      with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
      [
        opencode
        dsh
        antigravity-cli
      ]
    );
  };
}
