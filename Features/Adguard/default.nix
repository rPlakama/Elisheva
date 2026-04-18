{
  config,
  lib,
  ...
}:

let
  cfg = config.optionals.features.adguard;
in

{
  options.optionals.features.adguard.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Adguard Configuration";
    default = true;
  };
  config = lib.mkIf cfg.enable {
    services.adguardhome = {
      enable = true;
      openFirewall = true;
      mutableSettings = true;
    };
  };
}
