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
in
{
  options.features.ia-tools.enable = lib.mkEnableOption "General IA Tools";

  config = lib.mkIf featureCall.ia-tools.enable {

    hjem.users.${user}.packages = (
      with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
      [
        opencode
        dsh
      ]
    );
  };
}
