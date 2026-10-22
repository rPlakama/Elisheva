{
  config,
  lib,
  pkgs,
  ...
}:
let
  featureCall = config.features;
  domain = config.core.domain;
  ncHost = "nextcloud.${domain}";
in
{
  options.features.nextcloud.enable = lib.mkEnableOption "Nextcloud";

  config = lib.mkIf featureCall.nextcloud.enable {
    features.preservation.system.directories = [ "/var/lib/nextcloud" ];

    services.nextcloud = {
      package = pkgs.nextcloud35;
      enable = true;
      hostName = ncHost;
      https = true;

      database.createLocally = true;

      config = {
        dbtype = "pgsql";
      };

      settings = {
        overwriteprotocol = "https";
        default_phone_region = "BR";
      };
    };

    services.nginx.virtualHosts."${ncHost}" = {
      forceSSL = true;
      useACMEHost = domain;
      extraConfig = featureCall.unifiedDNS.accessControl;
    };

    services.pihole-ftl.settings.dns.hosts = [
      "${config.core.ip} ${ncHost}"
      "${featureCall.unifiedDNS.tailscaleIP} ${ncHost}"
    ];
  };
}
