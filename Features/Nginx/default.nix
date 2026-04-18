{
  config,
  lib,
  ...
}:

let
  cfg = config.optionals.features.nginx;
in

{
  options.optionals.features.nginx.enable = lib.mkOption {
    type = lib.types.bool;
    description = "nginx Configuration";
    default = false;
  };
  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
    };
  };
}
