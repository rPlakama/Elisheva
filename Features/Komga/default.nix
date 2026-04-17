{
  config,
  lib,
  ...
}:

let
  cfg = config.optionals.features.komga;
in

{
  options.optionals.features.komga.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Komga Configuration";
    default = false;
  };
  config = lib.mkIf cfg.enable {
    core.features.mediaPermissions.enable = true;
    services.komga = {
      enable = true;
      openFirewall = true;
      group = "media";
      settings.server.port = 3210;
    };
  };
}
