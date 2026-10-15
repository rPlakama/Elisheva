{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.searxng;
  dnsCfg = config.features.unifiedDNS;
  host = config.core.host;
  domain = config.core.domain;
  searxHost = "searxng.${domain}";
  searxPort = 8888;
  envFile = config.sops.templates."searxng.env".path;
  secret = config.sops.placeholder;

  instanceName = "${host} Search";
  contactUrl = "mailto:${dnsCfg.email}";
  locale = lib.replaceStrings [ "_" ".UTF-8" ] [ "-" "" ] config.i18n.extraLocaleSettings.LC_TIME;
  autocomplete = "duckduckgo";
  safeSearch = 0;
  imageProxy = true;
  publicInstance = false;
  enableMetrics = false;
  requestTimeout = 3.0;
  maxRequestTimeout = 6.0;

  keepEngines = [
    "duckduckgo"
    "duckduckgo images"
    "duckduckgo news"
    "duckduckgo videos"
    "brave"
    "brave.images"
    "brave.news"
    "brave.videos"
    "wikipedia"
    "wikidata"
    "wikinews"
    "wiktionary"
    "wikicommons.images"
    "wikicommons.videos"
    "openverse"
    "openstreetmap"
    "photon"
    "stackoverflow"
    "superuser"
    "askubuntu"
    "github"
    "gitlab"
    "codeberg"
    "mdn"
    "hackernews"
    "nixos wiki"
    "arch linux wiki"
    "docker hub"
    "pypi"
    "npm"
    "crates.io"
    "lib.rs"
    "hoogle"
    "mankier"
    "huggingface"
    "arxiv"
    "pubmed"
    "semantic scholar"
    "crossref"
    "europepmc"
    "openalex"
    "bandcamp"
    "soundcloud"
    "genius"
    "radio browser"
    "etymonline"
    "wttr.in"
    "openmeteo"
    "lingva"
    "imdb"
    "tmdb"
    "mastodon hashtags"
    "youtube"
    "vimeo"
    "peertube"
    "1337x"
    "piratebay"
    "solidtorrents"
    "annas archive"
    "unsplash"
    "pexels"
    "currency"
    "goodreads"
  ];
in
{
  options.features.searxng.enable = lib.mkEnableOption "Searxng module";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = dnsCfg.enable;
        message = "Searxng requires unifiedDNS for its DNS record and the reverse proxy";
      }
    ];

    sops.secrets."searxng/secret-key" = {
      owner = "searx";
      group = "searx";
      mode = "0400";
    };

    sops.templates."searxng.env".content = ''
      SEARXNG_SECRET_KEY=${secret."searxng/secret-key"}
    '';

    features = {
      preservation.system.directories = [
        "/var/lib/searx"
      ];
      unifiedDNS.proxyServices.searxng = {
        port = searxPort;
        icon = "si-searxng";
        description = "Privacy-respecting metasearch engine";
      };
    };

    services.searx = {
      enable = true;
      package = pkgs.searxng;
      environmentFile = envFile;

      settings = {
        use_default_settings.engines.keep_only = keepEngines;

        general = {
          instance_name = instanceName;
          contact_url = contactUrl;
          enable_metrics = enableMetrics;
        };

        server = {
          base_url = "https://${searxHost}/";
          bind_address = "127.0.0.1";
          port = searxPort;
          secret_key = "$SEARXNG_SECRET_KEY";
          image_proxy = imageProxy;
          public_instance = publicInstance;
        };

        search = {
          safe_search = safeSearch;
          autocomplete = autocomplete;
        };

        ui.default_locale = locale;

        outgoing = {
          request_timeout = requestTimeout;
          max_request_timeout = maxRequestTimeout;
        };
      };
    };
  };
}
