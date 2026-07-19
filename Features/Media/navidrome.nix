{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.navidrome;
  port = 4533;
  dataDir = "/var/lib/navidrome";
  musicGroup = "media";

  appleMusicPlugin = pkgs.fetchurl {
    name = "apple-music.ndp";
    url = "https://github.com/navidrome/apple-music-plugin/releases/download/v0.2.0/apple-music.ndp";
    hash = "sha256-NoJ1HnLKpcxGs/ercN5w6gJvCjikf3gLLStJIu0K0VQ=";
  };

  audioMusePlugin = pkgs.fetchurl {
    name = "audiomuseai.ndp";
    url = "https://github.com/NeptuneHub/AudioMuse-AI-NV-plugin/releases/download/v9/audiomuseai.ndp";
    hash = "sha256-vKC4SrKTWfNkpkX7qWjEV0ubyB71jG8z0DlXrjO1DPw=";
  };

  ndLyricsPlugin = pkgs.fetchurl {
    name = "nd-lyrics.ndp";
    url = "https://github.com/J0R6IT0/navidrome-lyrics-plugin/releases/download/v7.1.0/nd-lyrics.ndp";
    hash = "sha256-N0OJ0GuTWISvCjooxttRDl6O5GYDOomcPH6yClSFLOc=";
  };
in
{
  options.features.navidrome = {
    enable = lib.mkEnableOption "Navidrome music server";
    musicFolder = lib.mkOption {
      type = lib.types.str;
      default = "/media/music/library";
    };
  };

  config = lib.mkIf cfg.enable {
    features = {
      mediaPermissions = {
        enable = true;
      };
      preservation.system.directories = [ dataDir ];
      unifiedDNS.proxyServices.navidrome = port;
    };

    services.navidrome = {
      enable = true;
      group = musicGroup;
      settings = {
        Address = "127.0.0.1";
        Port = port;
        MusicFolder = cfg.musicFolder;
        DataFolder = dataDir;
        ScanSchedule = "@every 1h";
        EnableLyrics = true;
        EnableExternalServices = true;
        EnableGravatar = true;
        "Plugins.Enabled" = true;
        "Plugins.Folder" = "${dataDir}/plugins";
      };
    };

    systemd.services.navidrome.preStart = ''
      mkdir -p ${dataDir}/plugins
      cp -f ${appleMusicPlugin} ${dataDir}/plugins/apple-music.ndp
      cp -f ${audioMusePlugin} ${dataDir}/plugins/audiomuseai.ndp
      cp -f ${ndLyricsPlugin} ${dataDir}/plugins/nd-lyrics.ndp
    '';
  };
}
