{ config, lib, ... }:
let
  cfg = config.features.nzbget;
in
{
  options.features.nzbget.enable = lib.mkEnableOption "NZBGet usenet downloader";
  config = lib.mkIf cfg.enable {
    features = {
      mediaPermissions.enable = true;
      preservation.persistDirs.system = [ "/var/lib/nzbget" ];
    };
    services.nzbget = {
      enable = true;
      group = "media";
    };
    networking.firewall.allowedTCPPorts = [ 6789 ];
  };
}