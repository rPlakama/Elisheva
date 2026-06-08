{ config, lib, ... }:
let
  cfg = config.features.navidrome;
in
{
  options.features.navidrome.enable = lib.mkEnableOption "Navidrome music server";
  config = lib.mkIf cfg.enable {
    features = {
      mediaPermissions.enable = true;
      preservation.persistDirs.system = [ "/var/lib/navidrome" ];
      unifiedDNS.proxyServices.navidrome = 4533;
    };
    services.navidrome = {
      enable = true;
      group = "media";
      settings = {
        MusicFolder = "/media/music";
      };
    };
  };
}
