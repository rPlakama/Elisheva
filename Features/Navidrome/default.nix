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
  lyricsPlugin = pkgs.fetchurl {
    url = "https://github.com/J0R6IT0/navidrome-lyrics-plugin/releases/latest/download/nd-lyrics.ndp";
    hash = "sha256-U54KfULuMBDkJYzn4nuV8oKdaqJU20MMhnDv43rB9dY=";
  };
in
{
  options.features.navidrome = {
    enable = lib.mkEnableOption "Navidrome music server";
    musicFolder = lib.mkOption {
      type = lib.types.str;
      default = "/media/music/library";
      description = "Path to the music library";
    };
  };

  config = lib.mkIf cfg.enable {
    features = {
      preservation.persistDirs.system = [ "/var/lib/navidrome" ];
      mediaPermissions = {
        enable = true;
        writableServices = [ "navidrome" ];
      };
      unifiedDNS.proxyServices.navidrome = 4533;
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/navidrome/plugins 0750 navidrome media -"
      "L+ /var/lib/navidrome/plugins/apple-music.ndp - - - - ${appleMusicPlugin}"
      "L+ /var/lib/navidrome/plugins/nd-lyrics.ndp - - - - ${lyricsPlugin}"
    ];

    services = {
      navidrome = {
        enable = true;
        group = "media";
        settings = {
          "PID.Album" = "folder";
          MusicFolder = cfg.musicFolder;
          "Plugins.Enabled" = true;
          "Plugins.Folder" = "/var/lib/navidrome/plugins";
          Agents = "nd-lyrics, apple-music,deezer,listenbrainz";
          LyricsPriority = ".lrc,nd-lyrics,embedded";
          SaveLyrics = true;
        };
      };
    };
  };
}
