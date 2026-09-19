{
  lib,
  config,
  pkgs,
  ...
}:
let
  featureCall = config.features;
  user = config.core.user;
in
{
  options.features.devenv.enable = lib.mkEnableOption "Devenv";

  config = lib.mkIf featureCall.devenv.enable {
    hjem.users.${user}.packages = with pkgs; [ devenv ];
  };
}
