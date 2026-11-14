{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.sure;
  dnsCfg = config.features.unifiedDNS;
  app = pkgs.sure;
  secret = config.sops.placeholder;
  redisPort = 6379;
  envFile = config.sops.templates."sure.env".path;

  commonServiceConfig = {
    User = "sure";
    Group = "sure";
    WorkingDirectory = app;
    EnvironmentFile = [ envFile ];
    StateDirectory = "sure";
  };

  commonEnvironment = {
    RAILS_ENV = "production";
    RAILS_LOG_TO_STDOUT = "true";
    RAILS_SERVE_STATIC_FILES = "true";
    SELF_HOSTED = "true";
    DB_HOST = "/run/postgresql";
    DB_PORT = "5432";
    POSTGRES_USER = "sure";
    POSTGRES_DB = "sure";
    REDIS_URL = "redis://127.0.0.1:${toString redisPort}/1";
    APP_DOMAIN = "sure.${config.core.domain}";
  };
in
{
  options.features.sure = {
    enable = lib.mkEnableOption "Sure personal finance app";
    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Local port the Sure web server listens on";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = dnsCfg.enable;
        message = "Sure requires unifiedDNS for its DNS record and the reverse proxy";
      }
    ];

    sops.secrets."sure/secret-key-base" = {
      owner = "sure";
      group = "sure";
      mode = "0400";
    };

    sops.templates."sure.env".content = ''
      SECRET_KEY_BASE=${secret."sure/secret-key-base"}
    '';

    users.users.sure = {
      isSystemUser = true;
      group = "sure";
      home = "/var/lib/sure";
    };
    users.groups.sure = { };

    systemd.tmpfiles.rules = [
      "d /var/lib/sure 0750 sure sure -"
      "d /var/lib/sure/storage 0750 sure sure -"
      "d /var/lib/sure/tmp 0750 sure sure -"
      "d /var/lib/sure/log 0750 sure sure -"
      "d /run/sure 0750 sure sure -"
      "L+ /run/sure/storage - - - - /var/lib/sure/storage"
      "L+ /run/sure/tmp - - - - /var/lib/sure/tmp"
      "L+ /run/sure/log - - - - /var/lib/sure/log"
    ];

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "sure" ];
      ensureUsers = [
        {
          name = "sure";
          ensureDBOwnership = true;
        }
      ];
    };

    services.redis.servers.sure = {
      enable = true;
      port = redisPort;
      bind = "127.0.0.1";
    };

    systemd.services = {
      sure-migrate = {
        description = "Sure database migration";
        wantedBy = [ "multi-user.target" ];
        requires = [
          "postgresql.service"
          "redis-sure.service"
        ];
        after = [
          "postgresql.service"
          "redis-sure.service"
          "network-online.target"
        ];
        before = [
          "sure-web.service"
          "sure-worker.service"
        ];
        environment = commonEnvironment;
        serviceConfig = commonServiceConfig // {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${app}/bin/rails db:prepare";
        };
      };

      sure-web = {
        description = "Sure web server";
        wantedBy = [ "multi-user.target" ];
        requires = [ "sure-migrate.service" ];
        after = [
          "sure-migrate.service"
          "postgresql.service"
          "redis-sure.service"
          "network-online.target"
        ];
        environment = commonEnvironment;
        serviceConfig = commonServiceConfig // {
          ExecStart = "${app}/bin/rails server --binding 127.0.0.1 --port ${toString cfg.port}";
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };

      sure-worker = {
        description = "Sure Sidekiq worker";
        wantedBy = [ "multi-user.target" ];
        requires = [ "sure-migrate.service" ];
        after = [
          "sure-migrate.service"
          "postgresql.service"
          "redis-sure.service"
          "network-online.target"
        ];
        environment = commonEnvironment;
        serviceConfig = commonServiceConfig // {
          ExecStart = "${app}/bin/bundle exec sidekiq";
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };
    };

    features = {
      preservation.system.directories = [
        "/var/lib/sure"
        "/var/lib/postgresql"
        "/var/lib/redis-sure"
      ];

      unifiedDNS.proxyServices.sure = {
        port = cfg.port;
        icon = "mdi-finance";
        description = "Personal finance app";
      };
    };
  };
}
