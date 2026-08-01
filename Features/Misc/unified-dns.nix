{
  config,
  lib,
  ...
}:
let
  cfg = config.features.unifiedDNS;
  domain = config.core.domain;
  currentIP = config.core.ip;

  portOf = svc: if builtins.isInt svc then svc else svc.port;

  mkDnsRecords = ip: lib.mapAttrsToList (name: svc: "${ip} ${name}.${domain}") cfg.proxyServices;
in
{
  options.features.unifiedDNS = {
    enable = lib.mkEnableOption "Unified DNS and Reverse Proxy (Pi-hole + Nginx)";

    email = lib.mkOption {
      type = lib.types.str;
      description = "Email for ACME/Let's Encrypt notifications";
      default = "";
    };

    proxyServices = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.port
          (lib.types.submodule {
            options = {
              port = lib.mkOption {
                type = lib.types.port;
                description = "Service port";
              };
              icon = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "simple-icons slug shown on the homepage dashboard";
              };
              description = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Description shown on the homepage dashboard";
              };
            };
          })
        ]
      );
      default = { };
      description = "Services to be proxied by Nginx and registered in Pi-hole (a port or an attrset with port/icon/description)";
    };

    gateway = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "LAN gateway/router IP for Pi-hole DHCP";
    };

    tailscaleIP = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Tailscale IP of this machine for DNS records";
    };

    accessControl = lib.mkOption {
      type = lib.types.str;
      default = ''
        allow 192.168.1.0/24;
        allow 192.168.0.0/24;
        allow 100.64.0.0/10;
        allow 127.0.0.1;
        deny all;
      '';
      description = "Nginx access-control block applied to every proxied virtual host";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.email != "";
        message = "features.unifiedDNS.email must be set";
      }
      {
        assertion = cfg.gateway != "";
        message = "features.unifiedDNS.gateway must be set";
      }
      {
        assertion = cfg.tailscaleIP != "";
        message = "features.unifiedDNS.tailscaleIP must be set";
      }
    ];

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
          name: svc:
          lib.nameValuePair "${name}.${domain}" {
            useACMEHost = domain;
            forceSSL = true;
            extraConfig = cfg.accessControl;
            locations."/" = {
              proxyPass = "http://127.0.0.1:${toString (portOf svc)}";
              proxyWebsockets = true;
            };
          }
        ) cfg.proxyServices;
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = cfg.email;
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

    features.preservation.system.directories = [ "/etc/pihole" ];

    features.unifiedDNS.proxyServices.pi-hole = 8081;
  };
}
