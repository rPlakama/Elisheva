{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.generalMusicService;

  transcoderScript = pkgs.writeScriptBin "elisheva-music-transcoder" (
    builtins.replaceStrings [ "@MUSIC_DIR@" ] [ cfg.musicFolder ] (
      builtins.readFile ./general-music-service.py
    )
  );

  runtimePath = with pkgs; [
    python3
    ffmpeg
    coreutils
  ];
in
{
  options.features.generalMusicService = {
    enable = lib.mkEnableOption "FLAC→Opus transcoding and stale FLAC cleanup";
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
    systemd.services.elisheva-music-transcoder = {
      description = "Elisheva FLAC→Opus Transcoder";
      after = [
        "network-online.target"
        "media-music-library.mount"
      ];
      # Beets maintainer should run after transcoding finishes
      before = [ "elisheva-beets-maintainer.service" ];
      wants = [ "network-online.target" ];
      path = runtimePath;

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${transcoderScript}/bin/elisheva-music-transcoder ${cfg.musicFolder}";
        User = "nobody";
        Group = "media";
        Nice = 19;
        IOSchedulingClass = "idle";
        StandardOutput = "journal";
        StandardError = "journal";
        SyslogIdentifier = "elisheva-music-transcoder";
        PrivateTmp = true;
        NoNewPrivileges = true;
      };
    };

    systemd.timers.elisheva-music-transcoder = {
      description = "Periodic FLAC→Opus transcoding";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.timerConfig;
        RandomizedDelaySec = 120;
        Persistent = true;
      };
    };
  };
}
