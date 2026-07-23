{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.generalMusicService;

  maintainerScript = pkgs.writeScriptBin "elisheva-music-maintainer" (builtins.readFile ./GeneralMusicMaintainer.py);

  runtimePath = with pkgs; [ python3 ffmpeg flac coreutils ];
in
{
  options.features.generalMusicService = {
    enable = lib.mkEnableOption "General music maintenance (transcode + cleanup + covers + NFOs + lyrics)";
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
    systemd.services.elisheva-music-maintainer = {
      description = "Elisheva General Music Maintainer";
      after = [ "network-online.target" "media-music-library.mount" ];
      wants = [ "network-online.target" ];
      path = runtimePath;

      serviceConfig = {
        Type = "simple";
        ExecStart = "${maintainerScript}/bin/elisheva-music-maintainer ${cfg.musicFolder}";
        User = "nobody";
        Group = "media";
        Nice = 19;
        IOSchedulingClass = "idle";
        StandardOutput = "journal";
        StandardError = "journal";
        SyslogIdentifier = "elisheva-music-maintainer";
        PrivateTmp = true;
        NoNewPrivileges = true;
      };
    };

    systemd.timers.elisheva-music-maintainer = {
      description = "Periodic music library maintenance";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.timerConfig;
        RandomizedDelaySec = 300;
        Persistent = true;
      };
    };
  };
}
