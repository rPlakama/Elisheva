{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.beets;

  beetsPackage = pkgs.beets;
  beetsConfig = pkgs.writeText "beets-config.yaml" (
    builtins.toJSON {
      directory = cfg.musicFolder;
      library = "${cfg.dataDir}/musiclibrary.db";
      art_filename = "cover";

      import = {
        write = true;
        move = true;
        resume = false;
        quiet = true;
        quiet_fallback = "asis";
        from_scratch = false;
        log = "${cfg.dataDir}/import.log";
      };

      match = {
        strong_rec_thresh = 0.1;
        preferred = {
          countries = [
            "US"
            "GB"
            "XW"
            "JP"
          ];
          media = [
            "Digital Media|File"
            "CD"
          ];
          original_year = true;
        };
      };

      paths = {
        default = "%the{$albumartist}/$album%aunique{}/$track - $title";
        singleton = "Non-Album/%the{$artist}/$title";
        "comp:" = "Compilations/$album%aunique{}/$track - $title";
      };

      plugins = builtins.concatStringsSep " " [
        "chroma"
        "mbsync"
        "edit"
        "info"
        "fetchart"
        "embedart"
        "replaygain"
        "scrub"
        "lyrics"
        "duplicates"
        "missing"
        "unimported"
        "the"
        "ftintitle"
        "lastgenre"
        "parentwork"
        "zero"
      ];

      fetchart = {
        auto = true;
        minwidth = 500;
        maxwidth = 3000;
        cautious = true;
        cover_names = "cover front art album folder";
        sources = [
          "filesystem"
          "coverart"
          "itunes"
          "deezer"
          "amazon"
          "albumart"
          "wikipedia"
          "fanarttv"
        ];
        store_source = true;
      };

      embedart = {
        auto = true;
        ifempty = true;
        remove_art_file = false;
      };

      convert.auto = false;

      replaygain = {
        auto = true;
        backend = "ffmpeg";
        targetlevel = 89;
        r128 = [
          "opus"
          "flac"
        ];
      };

      scrub.auto = true;

      lyrics = {
        auto = true;
        synced = true;
        sources = [
          "lrclib"
          "genius"
          "musixmatch"
          "tekstowo"
        ];
        fallback = "Instrumental";
        force = false;
      };

      lastgenre = {
        auto = true;
        count = 3;
        fallback = "";
        canonical = true;
        source = "album";
      };

      zero = {
        fields = [
          "comments"
          "comment"
        ];
        update_database = true;
      };

      duplicates = {
        album = true;
        tiebreak.items = [ "bitrate" ];
      };

      chroma.auto = true;

      ftintitle = {
        auto = true;
        format = "(feat. {0})";
      };
    }
  );

  maintenanceScript = pkgs.writeShellScript "elisheva-beets-maintainer" ''
    set -euo pipefail

    export BEETSDIR="${cfg.dataDir}"
    export HOME="${cfg.dataDir}"
    BEET="${beetsPackage}/bin/beet -c ${beetsConfig}"
    MUSIC_DIR="${cfg.musicFolder}"

    log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"; }

    log "═══ Elisheva Beets Maintainer starting ═══"

    if [ -d "${cfg.incomingFolder}" ] && [ "$(ls -A "${cfg.incomingFolder}" 2>/dev/null)" ]; then
      log "Importing from ${cfg.incomingFolder}"
      $BEET import "${cfg.incomingFolder}" || true
    fi

    log "Updating existing library"
    $BEET import --quiet --incremental "$MUSIC_DIR" || true

    log "Fetching missing cover art"
    $BEET fetchart -q || true

    log "Fetching lyrics"
    $BEET lyrics || true

    log "Computing ReplayGain"
    $BEET replaygain -a || true

    log "Checking for duplicates"
    DUPS=$($BEET duplicates 2>/dev/null | head -50 || true)
    if [ -n "$DUPS" ]; then
      log "Found duplicates (first 50):"
      echo "$DUPS"
    fi

    log "═══ All phases complete ═══"
  '';

  runtimePath = with pkgs; [
    beetsPackage
    ffmpeg
    flac
    chromaprint
    coreutils
    imagemagick
  ];
in
{
  options.features.beets = {
    enable = lib.mkEnableOption "Beets music library manager";

    musicFolder = lib.mkOption {
      type = lib.types.str;
      default = "/media/music/library";
      description = "Music library root directory";
    };

    incomingFolder = lib.mkOption {
      type = lib.types.str;
      default = "/media/music/downloads";
      description = "Incoming music directory to auto-import from";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/beets";
      description = "Beets data directory (database, logs)";
    };

    timerConfig = lib.mkOption {
      type = lib.types.str;
      default = "*-*-* *:00:00";
      description = "systemd OnCalendar expression for periodic maintenance";
    };
  };

  config = lib.mkIf cfg.enable {
    features = {
      mediaPermissions.enable = true;
      preservation.system.directories = [ cfg.dataDir ];
    };

    environment.systemPackages = [
      beetsPackage
      pkgs.chromaprint
    ];

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 nobody media - -"
      "L+ ${cfg.dataDir}/config.yaml - - - - ${beetsConfig}"
    ];

    systemd.services.elisheva-beets-maintainer = {
      description = "Elisheva Beets Music Library Maintainer";
      after = [
        "network-online.target"
        "media-music-library.mount"
      ];
      wants = [ "network-online.target" ];
      path = runtimePath;

      serviceConfig = {
        Type = "simple";
        ExecStart = "${maintenanceScript}";
        User = "nobody";
        Group = "media";
        Nice = 19;
        IOSchedulingClass = "idle";
        StandardOutput = "journal";
        StandardError = "journal";
        SyslogIdentifier = "elisheva-beets";
        PrivateTmp = true;
        NoNewPrivileges = true;
        ReadWritePaths = [
          cfg.musicFolder
          cfg.incomingFolder
          cfg.dataDir
        ];
      };
    };

    systemd.timers.elisheva-beets-maintainer = {
      description = "Periodic beets music library maintenance";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.timerConfig;
        RandomizedDelaySec = 300;
        Persistent = true;
      };
    };
  };
}
