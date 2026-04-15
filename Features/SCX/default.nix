{
  config,
  lib,
  ...
}:

let
  cfg = config.optionals.features.scx;
in

{
  options.optionals.features.scx.enable = lib.mkOption {
    type = lib.types.bool;
    description = "SCX Configuration";
    default = false;
  };
  config = lib.mkIf cfg.enable {
    scx = {
      enable = true;
      scheduler = "scx_lavd";
    };
  };
}
