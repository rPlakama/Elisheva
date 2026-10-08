{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) optionals;
  featureCall = config.features;
  user = config.core.user;
  gpu = config.core.gpu;
in
{
  options.features.ia-tools.enable = lib.mkEnableOption "General IA Tools";

  config = lib.mkIf featureCall.ia-tools.enable {
    nixpkgs.overlays = [
    ];
    features = {
      preservation.home.directories = [
        ".ollama"
      ];
    };

    hjem.users.${user}.packages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
      opencode
      hermes-agent
    ];

    hjem.users.${user}.packages =
      with pkgs;
      optionals gpu.nvidia [ ollama-cuda ] ++ optionals gpu.amd [ ollama-rocm ];
  };
}
