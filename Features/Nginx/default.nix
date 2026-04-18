{
  config,
  lib,
  ...
}:

let
  cfg = config.optionals.features.nginx;
in

{
  options.optionals.features.nginx.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Nginx Configuration with SOPS SSL";
    default = false;
  };

  config = lib.mkIf cfg.enable {

    sops.secrets."nginx/moontier_key" = {
      owner = "nginx";
      group = "nginx";
      mode = "0400";
    };

    sops.secrets."nginx/moontier_crt" = {
      owner = "nginx";
      group = "nginx";
      mode = "0444";
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts."moontier.local" = {
        forceSSL = true;

        sslCertificate = config.sops.secrets."nginx/moontier_crt".path;
        sslCertificateKey = config.sops.secrets."nginx/moontier_key".path;

        extraConfig = ''
          allow 192.168.1.0/24;
          allow 127.0.0.1;
          deny all;
        '';

        locations."/evil" = {
          proxyPass = "http://192.168.1.106:8096";
          proxyWebsockets = true;
        };
      };
    };
  };
}
