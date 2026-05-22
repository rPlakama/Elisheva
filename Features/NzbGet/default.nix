{ config, lib, ... }:
let
  cfg = config.optionals.features.nzbget;
  persistEnabled = config.optionals.features.preservation.enable;
in
{
  options.optionals.features.nzbget.enable = lib.mkOption {
    type = lib.types.bool;
    description = "NZBget service";
    default = false;
  };
  config = lib.mkIf cfg.enable {
    core.features.mediaPermissions.enable = true;
    services.nzbget = {
      enable = true;
      group = "media";
    };
    networking.firewall.allowedTCPPorts = [ 6789 ];

    optionals.features.preservation.keepDirs.additionalDirs = lib.mkIf persistEnabled [
      "/var/lib/nzbget"
    ];
  };
}