{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.navidrome;
  port = 4533;

  # Beets configuration file for metadata and lyrics fetcher
  beetsConfigFile = pkgs.writeText "beets-navidrome.yaml" ''
    directory: ${cfg.musicFolder}
    library: /var/lib/navidrome/beets.db

    plugins: musicbrainz fetchart embedart lastgenre scrub lyrics

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
      sources: [filesystem, coverart, amazon, albumart]

    embedart:
      auto: yes
      remove_art_file: no

    lastgenre:
      auto: yes
      source: album

    lyrics:
      auto: yes
      fallback: ""
      sources: [google, musixmatch, tekstowo]
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
    metadataFetcher = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable automatic metadata & lyrics fetcher service (Beets plugins)";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    features = {
      mediaPermissions = {
        enable = true;
        writableServices = [
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

    # Systemd service + timer for Metadata & Lyrics Fetcher (Beets)
    systemd.services.navidrome-metadata-fetcher = lib.mkIf cfg.metadataFetcher.enable {
      description = "Navidrome Beets Metadata & Lyrics Fetcher Service";
      after = [ "network.target" ];
      path = [ pkgs.beets ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.beets}/bin/beet -c ${beetsConfigFile} import -q -A ${cfg.musicFolder}";
        User = "navidrome";
        Group = "media";
        Environment = "HOME=/var/lib/navidrome";
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
