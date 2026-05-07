{ config, lib, ... }:
let
  cfg = config.optionals.features.unifiedDNS;
  domain = config.core.domain;
  currentIP = config.core.ip;
  tailscaleIP = "100.119.129.77";

  mkDnsRecords = ip: lib.mapAttrsToList (name: port: "${ip} ${name}.${domain}") cfg.proxyServices;
in
{
  options.optionals.features.unifiedDNS = {
    enable = lib.mkEnableOption "Unified DNS and Reverse Proxy (Pi-hole + Nginx)";

    proxyServices = lib.mkOption {
      type = lib.types.attrsOf lib.types.port;
      default = { };
      description = "Services to be proxied by Nginx and registered in Pi-hole";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."hetzner/api" = {
      owner = "acme";
      group = "acme";
      mode = "0400";
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
      8081
    ];

    services = {
      pihole-ftl = {
        enable = true;
        settings.dns = {
          hosts = [
            "${currentIP} pi-hole"
            "${currentIP} ${domain}"
            "${tailscaleIP} ${domain}"
          ]
          ++ (mkDnsRecords currentIP)
          ++ (mkDnsRecords tailscaleIP);

          upstreams = [ "127.0.0.1#5335" ];
        };
      };

      unbound = {
        enable = true;
        settings = {
          server = {
            tcp-idle-timeout = 1000;
            interface = [
              "127.0.0.1"
              "::1"
            ];
            port = 5335;
            access-control = [
              "127.0.0.0/8 allow"
              "::1/128 allow"
            ];
            harden-glue = true;
            harden-dnssec-stripped = true;
            use-caps-for-id = false;
            edns-buffer-size = 1232;
            prefetch = true;
            num-threads = 1;
            qname-minimisation = true;
            do-not-query-localhost = false;
          };
        };
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "rPlakama@proton.me";
      certs."${domain}" = {
        inherit domain;
        extraDomainNames = [ "*.${domain}" ];
        dnsProvider = "hetzner";
        environmentFile = config.sops.secrets."hetzner/api".path;
        dnsResolver = "1.1.1.1:53";
        dnsPropagationCheck = true;
        group = "nginx";
        webroot = null;
      };
    };

    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = lib.mapAttrs' (
        name: port:
        lib.nameValuePair "${name}.${domain}" {
          useACMEHost = domain;
          forceSSL = true;
          extraConfig = ''
            allow 192.168.1.0/24;
            allow 100.64.0.0/10;
            allow 127.0.0.1;
            deny all;
          '';
          locations."/" = {
            proxyPass = "http://${currentIP}:${toString port}";
            proxyWebsockets = true;
          };
        }
      ) cfg.proxyServices;
    };

    optionals.features.unifiedDNS.proxyServices.pi-hole = 8081;
  };
}
