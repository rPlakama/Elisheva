{
  lib,
  config,
  ...
}:
let
  cfg = config.features.slskd;
  slskdPort = 5030;
  slskdListenPort = 50000;
in
{
  options.features.slskd.enable = lib.mkEnableOption "Soulseek client (container)";

  config = lib.mkIf cfg.enable {
    sops = {
      secrets = {
        "slskd/username" = { };
        "slskd/password" = { };
        "slskd/api-main" = { };
      };
      templates."slskd.env".content = ''
        SLSKD_SLSK_USERNAME=${config.sops.placeholder."slskd/username"}
        SLSKD_SLSK_PASSWORD=${config.sops.placeholder."slskd/password"}
        SLSKD_WEB__AUTHENTICATION__API_KEYS__TUBIFARRY__KEY=${config.sops.placeholder."slskd/api-main"}
        SLSKD_WEB__AUTHENTICATION__API_KEYS__TUBIFARRY__ROLE=ReadWrite
      '';
    };

    features = {
      mediaPermissions.enable = true;
      preservation.system.directories = [ "/var/lib/slskd" ];
      unifiedDNS.proxyServices.slskd = slskdPort;
    };

    networking.firewall.allowedTCPPorts = [ slskdListenPort ];

    # slskd writes as UID 1000, needs group write access to /var/lib/slskd
    systemd.tmpfiles.rules = [
      "d /var/lib/slskd 0775 1000 1000 - -"
    ];

    virtualisation.oci-containers = {
      backend = "podman";
      containers.slskd = {
        image = "docker.io/slskd/slskd:latest";
        ports = [
          "${toString slskdPort}:5030"
          "${toString slskdListenPort}:${toString slskdListenPort}"
        ];
        volumes = [
          "/var/lib/slskd:/app"
          "/media:/media"
        ];
        environment = {
          PUID = toString config.users.users.${config.core.user}.uid;
          PGID = toString config.users.users.${config.core.user}.uid;
          SLSKD_REMOTE_CONFIGURATION = "true";
          SLSKD_URL_BASE = "/slskd";
          SLSKD_SHARED_DIR = "-/media/music/downloads;/media/music";
          SLSKD_DOWNLOADS_DIR = "/media/music/library";
          SLSKD_SLSK_LISTEN_PORT = toString slskdListenPort;
        };
        environmentFiles = [
          config.sops.templates."slskd.env".path
        ];
        autoStart = true;
      };
    };
  };
}
