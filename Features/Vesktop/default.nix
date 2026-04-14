{
  config,
  lib,
  ...
}:

let
  cfg = config.mySystem.features.vesktop;
  user = config.core.user;
in

{
  options.mySystem.features.vesktop.enable = lib.mkEnableOption {
    type = lib.types.bool;
    description = "Vesktop, a better Discord for Linux";
    default = true;
  };
  config = lib.mkIf cfg.enable {
    home-manger.${user} = { };

  };
}
