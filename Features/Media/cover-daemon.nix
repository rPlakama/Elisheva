{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.coverDaemon;

  coverScript = pkgs.writeScriptBin "elisheva-cover-fetcher" (builtins.readFile ./cover-daemon.py);
in
{
  options.features.coverDaemon = {
    enable = lib.mkEnableOption "Cover art fetcher daemon";
    musicFolder = lib.mkOption {
      type = lib.types.str;
      default = "/media/music/library";
      description = "Music library root to scan for album covers";
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
      after = [
        "network-online.target"
        "media-music-library.mount"
      ];
      wants = [ "network-online.target" ];
      path = with pkgs; [
        python3
        ffmpeg
        flac
      ];

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

    systemd.timers.elisheva-cover-daemon = {
      description = "Periodic cover art fetch";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.timerConfig;
        RandomizedDelaySec = 300;
        Persistent = true;
      };
    };
  };
}
