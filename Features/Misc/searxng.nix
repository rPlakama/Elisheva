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
  limiter = true;
  publicInstance = false;
  enableMetrics = false;
  requestTimeout = 6.0;
  maxRequestTimeout = 12.0;
  realIp = {
    x_for = 1;
    ipv4_prefix = 32;
    ipv6_prefix = 56;
  };
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
        "/var/lib/redis-searx"
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
      redisCreateLocally = true;
      environmentFile = envFile;

      settings = {
        use_default_settings.engines.remove = [
          "ahmia"
          "torch"
        ];

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
          limiter = limiter;
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

      limiterSettings = {
        real_ip = realIp;
      };
    };
  };
}
