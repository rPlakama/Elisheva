{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.transcode;

  transcoderScript = pkgs.writeScriptBin "elisheva-transcoder" (
    builtins.replaceStrings [ "@MUSIC_DIR@" ] [ cfg.musicFolder ] (builtins.readFile ./transcode.py)
  );

  runtimePath = with pkgs; [
    python3
    ffmpeg
    coreutils
  ];
in
{
  options.features.transcode = {
    enable = lib.mkEnableOption "FLAC→Opus transcoding and stale FLAC cleanup";
    musicFolder = lib.mkOption {
      type = lib.types.str;
      default = "/media/music/library";
      description = "Music library root";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.elisheva-transcoder = {
      description = "Elisheva FLAC→Opus Transcoder";
      after = [
        "network-online.target"
        "media-music-library.mount"
      ];
      wants = [ "network-online.target" ];
      path = runtimePath;

      serviceConfig = {
        Type = "simple";
        ExecStart = "${transcoderScript}/bin/elisheva-transcoder ${cfg.musicFolder}";
        User = "nobody";
        Group = "media";
        Nice = 19;
        IOSchedulingClass = "idle";
        StandardOutput = "journal";
        StandardError = "journal";
        SyslogIdentifier = "elisheva-transcoder";
        PrivateTmp = true;
        NoNewPrivileges = true;
      };
    };

    systemd.timers.elisheva-transcoder = {
      description = "FLAC→Opus transcoding on library changes";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnUnitInactiveSec = "5m";
        Persistent = true;
      };
    };

    systemd.paths.elisheva-transcoder = {
      description = "Watch music library for new FLAC files";
      wantedBy = [ "paths.target" ];
      pathConfig = {
        PathChanged = cfg.musicFolder;
        Unit = "elisheva-transcoder.service";
      };
    };
  };
}
