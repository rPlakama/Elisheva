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
  options.features.devenv = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "DevEnv as default impl";
    };
  };

  config = lib.mkIf featureCall.devenv.enable {
    hjem.users.${user}.packages = with pkgs; [ devenv ];
  };
}
