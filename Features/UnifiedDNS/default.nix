{ config, lib, ... }:
let
  cfg = config.features.unifiedDNS;
  domain = config.core.domain;
  currentIP = config.core.ip;

  mkDnsRecords = ip: lib.mapAttrsToList (name: port: "${ip} ${name}.${domain}") cfg.proxyServices;
in
{
  options.features.unifiedDNS = {
    enable = lib.mkEnableOption "Unified DNS and Reverse Proxy (Pi-hole + Nginx)";

    proxyServices = lib.mkOption {
      type = lib.types.attrsOf lib.types.port;
      default = { };
      description = "Services to be proxied by Nginx and registered in Pi-hole";
    };

    gateway = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.1";
      description = "LAN gateway/router IP for Pi-hole DHCP";
    };

    tailscaleIP = lib.mkOption {
      type = lib.types.str;
      default = "100.119.129.77";
      description = "Tailscale IP of this machine for DNS records";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."hetzner/api" = {
      owner = "acme";
      group = "acme";
      mode = "0400";
    };

    networking.firewall = {
      trustedInterfaces = [ "tailscale0" ];
      allowedTCPPorts = [
        80
        443
        8081
      ];
    };

    systemd.tmpfiles.rules = [
      "f /etc/pihole/versions 0644 pihole pihole - -"
    ];

    services = {
      resolved.settings.Resolve = {
        DNSStubListener = "no";
        MulticastDNS = "no";
      };

      unbound = {
        enable = true;
        settings.server = {
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

      pihole-ftl = {
        enable = true;
        openFirewallDNS = true;
        openFirewallDHCP = true;
        openFirewallWebserver = true;
        queryLogDeleter.enable = true;
        useDnsmasqConfig = true;
        settings = {
          dhcp = {
            active = false;
            end = "192.168.0.254";
            hosts = [ ];
            ipv6 = false;
            leaseTime = "24h";
            start = "192.168.0.61";
            rapidCommit = true;
            resolver.resolveIPv6 = false;
            router = cfg.gateway;
          };
          dns = {
            cnameRecords = [ ];
            domain = domain;
            domainNeeded = true;
            listeningMode = "ALL";
            expandHosts = true;
            interface = "all";
            hosts = [
              "${cfg.gateway} gateway"
              "${currentIP} pi-hole"
              "${currentIP} ${domain}"
              "${cfg.tailscaleIP} ${domain}"
            ]
            ++ (mkDnsRecords currentIP)
            ++ (mkDnsRecords cfg.tailscaleIP);
            upstreams = [ "127.0.0.1#5335" ];
          };
          ntp = {
            ipv4.active = false;
            ipv6.active = false;
            sync.active = false;
          };
          webserver.api.pwhash = "";
          session.timeout = 43200;
        };
      };

      pihole-web = {
        enable = true;
        ports = [ 8081 ];
      };

      nginx = {
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
              proxyPass = "http://127.0.0.1:${toString port}";
              proxyWebsockets = true;
            };
          }
        ) cfg.proxyServices;
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

    features.unifiedDNS.proxyServices.pi-hole = 8081;
  };
}
