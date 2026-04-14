{ config, lib }:

let
  cfg = config.optionals.features.nzbget;
in
{

  options.optionals.features.nzbget.enable = lib.mkEnableOption {
    description = "An usernet downloader";
    type = lib.types.bool;
    default = false;
  };
  config = lib.mkIf cfg.enable {
  };

}
