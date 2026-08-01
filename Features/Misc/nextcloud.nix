{
  config,
  lib,
  ...
}:
let
  cfg = config.features.nextcloud;
  domain = config.core.domain;
  ncHost = "nextcloud.${domain}";
in
{
  options.features.nextcloud.enable = lib.mkEnableOption "Nextcloud";

  config = lib.mkIf cfg.enable {
    features.preservation.system.directories = [ "/var/lib/nextcloud" ];

    sops.secrets."nextcloud/admin" = {
      owner = "nextcloud";
      group = "nextcloud";
      mode = "0400";
    };
    services.nextcloud = {
      enable = true;
      hostName = ncHost;
      https = true;

      database.createLocally = true;

      config = {
        dbtype = "pgsql";
        adminpassFile = config.sops.secrets."nextcloud/admin".path;
      };

      settings = {
        overwriteprotocol = "https";
        default_phone_region = "BR";
      };
    };

    services.nginx.virtualHosts."${ncHost}" = {
      forceSSL = true;
      useACMEHost = domain;
      extraConfig = config.features.unifiedDNS.accessControl;
    };

    services.pihole-ftl.settings.dns.hosts = [
      "${config.core.ip} ${ncHost}"
      "${config.features.unifiedDNS.tailscaleIP} ${ncHost}"
    ];
  };
}
