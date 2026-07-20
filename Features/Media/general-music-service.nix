{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.generalMusicService;

  coverScript = pkgs.writeScriptBin "elisheva-cover-fetcher" (builtins.readFile ./cover-daemon.py);
  lyricsScript = pkgs.writeScriptBin "elisheva-lyrics-fetcher" (builtins.readFile ./lyrics-daemon.py);
  transcodeScript = pkgs.writeScriptBin "elisheva-transcode" (builtins.readFile ./transcode.sh);

  pythonPath = [ pkgs.python3 pkgs.ffmpeg pkgs.flac ];
  transcodePath = with pkgs; [ bash coreutils findutils ffmpeg ];
in
{
  options.features.generalMusicService = {
    enable = lib.mkEnableOption "General music metadata services (covers + lyrics + transcode)";
    musicFolder = lib.mkOption {
      type = lib.types.str;
      default = "/media/music/library";
      description = "Music library root";
    };
    timerConfig = lib.mkOption {
      type = lib.types.str;
      default = "*-*-* *:00:00";
      description = "systemd OnCalendar expression for periodic scans";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.elisheva-cover-daemon = {
      description = "Elisheva Cover Art Fetcher";
      after = [ "network-online.target" "media-music-library.mount" ];
      wants = [ "network-online.target" ];
      path = pythonPath;

      serviceConfig = {
        Type = "simple";
        ExecStart = "${coverScript}/bin/elisheva-cover-fetcher ${cfg.musicFolder}";
        User = "nobody";
        Group = "media";
        Nice = 19;
        IOSchedulingClass = "idle";
        StandardOutput = "journal";
        StandardError = "journal";
        SyslogIdentifier = "elisheva-cover-daemon";
        PrivateTmp = true;
        NoNewPrivileges = true;
      };
    };

    systemd.services.elisheva-lyrics-daemon = {
      description = "Elisheva Lyrics Fetcher";
      after = [ "network-online.target" "media-music-library.mount" ];
      wants = [ "network-online.target" ];
      path = pythonPath;

      serviceConfig = {
        Type = "simple";
        ExecStart = "${lyricsScript}/bin/elisheva-lyrics-fetcher ${cfg.musicFolder}";
        User = "nobody";
        Group = "media";
        Nice = 19;
        IOSchedulingClass = "idle";
        StandardOutput = "journal";
        StandardError = "journal";
        SyslogIdentifier = "elisheva-lyrics-daemon";
        PrivateTmp = true;
        NoNewPrivileges = true;
      };
    };

    systemd.services.elisheva-transcode-daemon = {
      description = "Elisheva FLAC-to-Opus Transcoder";
      after = [ "media-music-library.mount" ];
      path = transcodePath;

      serviceConfig = {
        Type = "simple";
        ExecStart = "${transcodeScript}/bin/elisheva-transcode ${cfg.musicFolder}";
        User = "nobody";
        Group = "media";
        Nice = 19;
        IOSchedulingClass = "idle";
        StandardOutput = "journal";
        StandardError = "journal";
        SyslogIdentifier = "elisheva-transcode-daemon";
        PrivateTmp = true;
        NoNewPrivileges = true;
      };
    };

    systemd.timers.elisheva-cover-daemon = {
      description = "Periodic cover art fetch";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.timerConfig;
        RandomizedDelaySec = 300;
        Persistent = true;
      };
    };

    systemd.timers.elisheva-lyrics-daemon = {
      description = "Periodic lyrics fetch";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.timerConfig;
        RandomizedDelaySec = 300;
        Persistent = true;
      };
    };

    systemd.timers.elisheva-transcode-daemon = {
      description = "Periodic FLAC transcode";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.timerConfig;
        RandomizedDelaySec = 300;
        Persistent = true;
      };
    };
  };
}
