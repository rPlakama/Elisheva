{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.navidrome;

  appleMusicPlugin = pkgs.fetchurl {
    url = "https://github.com/navidrome/apple-music-plugin/releases/download/v0.1.0/apple-music.ndp";
    hash = "sha256-X6lkXQg80jPBZ7sBJ4c80p2lb/KK3uZDd57CbZkSESs=";
  };
in
{
  options.features.navidrome = {
    enable = lib.mkEnableOption "Navidrome music server";
    musicFolder = lib.mkOption {
      type = lib.types.str;
      default = "/media/music";
      description = "Path to the music library";
    };
  };

  config = lib.mkIf cfg.enable {
    features = {
      mediaPermissions.enable = true;
      preservation.persistDirs.system = [ "/var/lib/navidrome" ];
      unifiedDNS.proxyServices.navidrome = 4533;
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/navidrome/plugins 0750 navidrome media -"
      "L+ /var/lib/navidrome/plugins/apple-music.ndp - - - - ${appleMusicPlugin}"
    ];

    services.navidrome = {
      enable = true;
      group = "media";
      settings = {
        MusicFolder = cfg.musicFolder;
        "Plugins.Enabled" = true;
        "Plugins.Folder" = "/var/lib/navidrome/plugins";
        Agents = "apple-music,deezer,listenbrainz";
      };
    };
  };
}
