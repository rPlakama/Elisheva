{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.navidrome;
  port = 4533;

  pythonEnv = pkgs.python3.withPackages (
    ps: with ps; [
      syncedlyrics
      mutagen
    ]
  );

  # Lyrics fetcher script using syncedlyrics + mutagen
  lyricsFetcherScript = pkgs.writeScriptBin "navidrome-lyrics-fetcher" ''
    #!${pythonEnv}/bin/python3
    import os
    import sys
    import logging
    from pathlib import Path
    import mutagen
    import syncedlyrics

    fmt = "%(asctime)s [%(levelname)s] %(message)s"
    logging.basicConfig(level=logging.INFO, format=fmt)
    logger = logging.getLogger("lyrics-fetcher")

    music_dir = Path("${cfg.musicFolder}")
    if not music_dir.exists():
        logger.error(f"Music directory {music_dir} does not exist!")
        sys.exit(1)

    AUDIO_EXTENSIONS = {
        ".mp3", ".flac", ".m4a", ".ogg",
        ".opus", ".wav", ".aac", ".alac"
    }

    logger.info(f"Starting lyrics scan in {music_dir}...")
    fetched_count = 0
    skipped_count = 0

    for root, _, files in os.walk(music_dir):
        for file in files:
            ext = Path(file).suffix.lower()
            if ext not in AUDIO_EXTENSIONS:
                continue

            audio_path = Path(root) / file
            lrc_path = audio_path.with_suffix(".lrc")
            lyrc_path = audio_path.with_suffix(".lyrc")

            # Check if synced lyrics file already exists
            if lrc_path.exists() or lyrc_path.exists():
                skipped_count += 1
                continue

            # Extract title and artist using mutagen
            title, artist = None, None
            try:
                tags = mutagen.File(audio_path)
                if tags:
                    if "TIT2" in tags:  # ID3
                        title = str(tags["TIT2"])
                    elif "title" in tags:
                        title = str(tags["title"][0])

                    if "TPE1" in tags:  # ID3
                        artist = str(tags["TPE1"])
                    elif "artist" in tags:
                        artist = str(tags["artist"][0])
            except Exception as e:
                logger.warning(f"Metadata error for {audio_path}: {e}")

            if not title:
                title = audio_path.stem

            query = f"{title} {artist}" if artist else title
            logger.info(f"Fetching lyrics for: {query}")

            try:
                lrc = syncedlyrics.search(query)
                if lrc:
                    # Write both .lrc and .lyrc for maximum compatibility
                    lrc_path.write_text(lrc, encoding="utf-8")
                    lyrc_path.write_text(lrc, encoding="utf-8")
                    fetched_count += 1
                    logger.info(f"Saved lyrics for {file}")
                else:
                    logger.info(f"No lyrics found for {file}")
            except Exception as e:
                logger.error(f"Error fetching lyrics for {file}: {e}")

    logger.info(
        f"Lyrics scan complete. Fetched: {fetched_count}, "
        f"Skipped: {skipped_count}"
    )
  '';

  # Beets configuration file for metadata fetcher
  beetsConfigFile = pkgs.writeText "beets-navidrome.yaml" ''
    directory: ${cfg.musicFolder}
    library: /var/lib/navidrome/beets.db

    plugins: musicbrainz fetchart embedart lastgenre scrub

    import:
      write: yes
      copy: no
      move: no
      autotag: yes
      quiet: yes
      resume: yes

    fetchart:
      auto: yes
      minwidth: 500
      maxwidth: 1400
      sources: filesystem coverart amazon albumart

    embedart:
      auto: yes
      remove_art_file: no

    lastgenre:
      auto: yes
      source: album
  '';
in
{
  options.features.navidrome = {
    enable = lib.mkEnableOption "Navidrome music server";
    musicFolder = lib.mkOption {
      type = lib.types.str;
      default = "/media/music/library";
      description = "Music folder path for Navidrome library";
    };
    lyricsFetcher = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable automatic synced lyrics fetcher (.lrc & .lyrc generator)";
      };
    };
    metadataFetcher = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable automatic metadata & cover art fetcher service (MusicBrainz/Beets)";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    features = {
      mediaPermissions = {
        enable = true;
        writableServices = [
          "navidrome-lyrics-fetcher"
          "navidrome-metadata-fetcher"
        ];
      };
      preservation.system.directories = [ "/var/lib/navidrome" ];
      unifiedDNS.proxyServices.navidrome = port;
    };

    services.navidrome = {
      enable = true;
      group = "media";
      openFirewall = true;
      settings = {
        Address = "0.0.0.0";
        Port = port;
        MusicFolder = cfg.musicFolder;
        DataFolder = "/var/lib/navidrome";
        ScanSchedule = "@every 1h";
        EnableLyrics = true;
        EnableExternalServices = true;
        EnableGravatar = true;
      };
    };

    # Systemd service + timer for Lyrics Fetcher (.lrc / .lyrc creation)
    systemd.services.navidrome-lyrics-fetcher = lib.mkIf cfg.lyricsFetcher.enable {
      description = "Navidrome Synced Lyrics Fetcher Service (.lrc & .lyrc generator)";
      after = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lyricsFetcherScript}/bin/navidrome-lyrics-fetcher";
        User = "navidrome";
        Group = "media";
      };
    };

    systemd.timers.navidrome-lyrics-fetcher = lib.mkIf cfg.lyricsFetcher.enable {
      description = "Timer for Navidrome Synced Lyrics Fetcher";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "2h";
      };
    };

    # Systemd service + timer for Metadata Fetcher (MusicBrainz & Beets)
    systemd.services.navidrome-metadata-fetcher = lib.mkIf cfg.metadataFetcher.enable {
      description = "Navidrome MusicBrainz & Beets Metadata Fetcher Service";
      after = [ "network.target" ];
      path = [ pkgs.beets ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.beets}/bin/beet -c ${beetsConfigFile} import -q -A ${cfg.musicFolder}";
        User = "navidrome";
        Group = "media";
      };
    };

    systemd.timers.navidrome-metadata-fetcher = lib.mkIf cfg.metadataFetcher.enable {
      description = "Timer for Navidrome Metadata Fetcher";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "10m";
        OnUnitActiveSec = "6h";
      };
    };
  };
}
