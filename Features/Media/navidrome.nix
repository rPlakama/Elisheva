{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.navidrome;

  audioMusePlugin = pkgs.fetchurl {
    url = "https://github.com/NeptuneHub/AudioMuse-AI-NV-plugin/releases/download/v9/audiomuseai.ndp";
    hash = "sha256-vKC4SrKTWfNkpkX7qWjEV0ubyB71jG8z0DlXrjO1DPw=";
  };
  appleMusicPlugin = pkgs.fetchurl {
    url = "https://github.com/navidrome/apple-music-plugin/releases/download/v0.2.0/apple-music.ndp";
    hash = "sha256-NoJ1HnLKpcxGs/ercN5w6gJvCjikf3gLLStJIu0K0VQ=";
  };
  lyricsPlugin = pkgs.fetchurl {
    url = "https://github.com/J0R6IT0/navidrome-lyrics-plugin/releases/latest/download/nd-lyrics.ndp";
    hash = "sha256-N0OJ0GuTWISvCjooxttRDl6O5GYDOomcPH6yClSFLOc=";
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
      preservation.system.directories = [ "/var/lib/navidrome" ];
      mediaPermissions = {
        enable = true;
        writableServices = [ "navidrome" ];
      };
      unifiedDNS.proxyServices.navidrome = 4533;
      coverDaemon = {
        enable = lib.mkDefault true;
        musicFolder = lib.mkDefault cfg.musicFolder;
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/navidrome/plugins 0750 navidrome media -"
      "L+ /var/lib/navidrome/plugins/apple-music.ndp - - - - ${appleMusicPlugin}"
      "L+ /var/lib/navidrome/plugins/audiomuseai.ndp - - - - ${audioMusePlugin}"
      "L+ /var/lib/navidrome/plugins/nd-lyrics.ndp - - - - ${lyricsPlugin}"
    ];

    services.navidrome = {
      enable = true;
      group = "media";
      settings = {
        "PID.Album" = "folder";
        MusicFolder = cfg.musicFolder;
        "Plugins.Enabled" = true;
        "Plugins.Folder" = "/var/lib/navidrome/plugins";
        Agents = "nd-lyrics,apple-music,audiomuseai,deezer,listenbrainz";
        LyricsPriority = ".lrc,nd-lyrics,embedded";
        SaveLyrics = true;
      };
    };
  };
}
