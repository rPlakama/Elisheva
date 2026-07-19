{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.navidrome;
  port = 4533;
  dataDir = "/var/lib/navidrome";
  musicGroup = "media";

  beetExec = "${pkgs.beets}/bin/beet -c ${config.sops.templates."beets-navidrome.yaml".path} import -q -A ${cfg.musicFolder}";
in {
  options.features.navidrome = {
    enable = lib.mkEnableOption "Navidrome music server";
    musicFolder = lib.mkOption {
      type = lib.types.str;
      default = "/media/music/library";
    };
    metadataFetcher = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."beets/google_api_key" = {};
    sops.secrets."beets/google_engine_id" = {};

    sops.templates."beets-navidrome.yaml" = {
      owner = "navidrome";
      content = ''
        directory: ${cfg.musicFolder}
        library: ${dataDir}/beets.db

        plugins: musicbrainz fetchart embedart lastgenre scrub lyrics

        import:
          write: yes
          copy: no
          move: no
          autotag: yes
          quiet: yes
          resume: yes
          incremental: yes

        fetchart:
          auto: yes
          minwidth: 500
          maxwidth: 1400
          enforce_ratio: yes
          cautious: yes
          cover_names: [cover, front, art, album, folder]
          sources: [filesystem, id3, coverart, itunes, amazon, albumart, wikipedia, google]

        embedart:
          auto: yes
          remove_art_file: no

        lastgenre:
          auto: yes
          source: album

        lyrics:
          auto: yes
          fallback: ""
          sources: [google, lrclib, musixmatch, genius, tekstowo]
          google_API_key: ${config.sops.placeholder."beets/google_api_key"}
          google_engine_ID: ${config.sops.placeholder."beets/google_engine_id"}
      '';
    };

    features = {
      mediaPermissions = {
        enable = true;
        writableServices = ["navidrome-metadata-fetcher"];
      };
      preservation.system.directories = [dataDir];
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
      };
    };

    systemd.services.navidrome-metadata-fetcher = lib.mkIf cfg.metadataFetcher.enable {
      after = ["network.target"];
      path = [pkgs.beets];
      restartIfChanged = false;
      serviceConfig = {
        Type = "simple";
        ExecStart = beetExec;
        User = "navidrome";
        Group = musicGroup;
        Environment = "HOME=${dataDir}";
        UMask = "0002";
      };
    };

    systemd.timers.navidrome-metadata-fetcher = lib.mkIf cfg.metadataFetcher.enable {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "10m";
        OnUnitActiveSec = "6h";
      };
    };
  };
}
