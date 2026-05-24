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
      extraConfig = ''
        allow 192.168.1.0/24;
        allow 100.64.0.0/10;
        allow 127.0.0.1;
        deny all;
      '';
    };

    services.pihole-ftl.settings.dns.hosts = [
      "${config.core.ip} ${ncHost}"
      "${config.features.unifiedDNS.tailscaleIP} ${ncHost}"
    ];
  };
}
