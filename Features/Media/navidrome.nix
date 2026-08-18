{
  config,
  lib,
  pkgs,
  ...
}: let
  featureCall = config.features;

  appleMusicPlugin = pkgs.fetchurl {
    url = "https://github.com/navidrome/apple-music-plugin/releases/download/v0.2.0/apple-music.ndp";
    hash = "sha256-NoJ1HnLKpcxGs/ercN5w6gJvCjikf3gLLStJIu0K0VQ=";
  };
in {
  options.features.navidrome = {
    enable = lib.mkEnableOption "Navidrome music server";
    musicFolder = lib.mkOption {
      type = lib.types.str;
      default = "/media/music/library";
      description = "Path to the music library";
    };
  };

  config = lib.mkIf featureCall.navidrome.enable {
    features = {
      preservation.system.directories = ["/var/lib/navidrome"];
      mediaPermissions = {
        enable = true;
        writableServices = ["navidrome"];
      };
      unifiedDNS.proxyServices.navidrome = {
        port = 4533;
        icon = "sh-navidrome";
        description = "Music streaming server";
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/navidrome/plugins 0750 navidrome media -"
      "L+ /var/lib/navidrome/plugins/apple-music.ndp - - - - ${appleMusicPlugin}"
    ];

    services.navidrome = {
      enable = true;
      group = "media";
      settings = {
        "PID.Album" = "folder";
        MusicFolder = featureCall.navidrome.musicFolder;
        "Plugins.Enabled" = true;
        "Scanner"."PurgeMissing" = "full";
        "Plugins.Folder" = "/var/lib/navidrome/plugins";
        Agents = "nd-lyrics,apple-music,audiomuseai,deezer,listenbrainz";
        LyricsPriority = ".lrc,nd-lyrics,embedded";
        SaveLyrics = true;
      };
    };
  };
}
