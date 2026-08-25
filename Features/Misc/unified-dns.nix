{
  config,
  lib,
  ...
}: let
  featureCall = config.features;
  domain = config.core.domain;
  currentIP = config.core.ip;

  portOf = svc:
    if builtins.isInt svc
    then svc
    else svc.port;

  mkDnsRecords = ip: lib.mapAttrsToList (name: svc: "${ip} ${name}.${domain}") featureCall.unifiedDNS.proxyServices;
in {
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
      default = {};
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

  config = lib.mkIf featureCall.unifiedDNS.enable {
    assertions = [
      {
        assertion = featureCall.unifiedDNS.email != "";
        message = "features.unifiedDNS.email must be set";
      }
      {
        assertion = featureCall.unifiedDNS.gateway != "";
        message = "features.unifiedDNS.gateway must be set";
      }
      {
        assertion = featureCall.unifiedDNS.tailscaleIP != "";
        message = "features.unifiedDNS.tailscaleIP must be set";
      }
    ];

    sops.secrets."hetzner/api" = {
      owner = "acme";
      group = "acme";
      mode = "0400";
    };

    services.tailscale.extraSetFlags = ["--accept-dns=false"];

    networking.firewall = {
      trustedInterfaces = ["tailscale0"];
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
        MulticastDNS = "yes";
      };

      pihole-ftl = {
        enable = true;
        openFirewallDNS = true;
        openFirewallDHCP = true;
        openFirewallWebserver = true;
        queryLogDeleter.enable = true;
        useDnsmasqConfig = true;
        lists = [
          {
            url = "https://big.oisd.nl/";
            description = "OISD Full - ads, trackers, malware";
          }
          {
            url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
            description = "StevenBlack Unified hosts - ads, malware";
          }
          {
            url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling/hosts";
            description = "StevenBlack Gambling - betting & gambling sites";
          }
          {
            url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling/hosts";
            description = "StevenBlack Fakenews + Gambling - fake news & betting";
          }
          {
            url = "https://adaway.org/hosts.txt";
            description = "AdAway - mobile ads";
          }
          {
            url = "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext";
            description = "Peter Lowe's Adservers";
          }
          {
            url = "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt";
            description = "AnudeepND Adservers";
          }
          {
            url = "https://v.firebog.net/hosts/AdguardDNS.txt";
            description = "AdGuard DNS filter";
          }
          {
            url = "https://v.firebog.net/hosts/Easylist.txt";
            description = "EasyList - ads";
          }
          {
            url = "https://v.firebog.net/hosts/Easyprivacy.txt";
            description = "EasyPrivacy - trackers";
          }
          {
            url = "https://v.firebog.net/hosts/Prigent-Ads.txt";
            description = "Prigent Ads";
          }
          {
            url = "https://v.firebog.net/hosts/Prigent-Malware.txt";
            description = "Prigent Malware";
          }
          {
            url = "https://v.firebog.net/hosts/Prigent-Crypto.txt";
            description = "Prigent Cryptojacking";
          }
          {
            url = "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt";
            description = "DandelionSprout Anti-Malware";
          }
          {
            url = "https://urlhaus.abuse.ch/downloads/hostfile/";
            description = "URLhaus Malware domains";
          }
          {
            url = "https://phishing.army/download/phishing_army_blocklist_extended.txt";
            description = "Phishing Army Extended";
          }
          {
            url = "https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt";
            description = "Spam404 blacklist";
          }
          {
            url = "https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt";
            description = "KADhosts - ad/telemetry/spam";
          }
          {
            url = "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts";
            description = "FadeMind Spam";
          }
          {
            url = "https://raw.githubusercontent.com/matomo-org/referrer-spam-blacklist/master/spammers.txt";
            description = "Matomo Referrer Spam";
          }
          {
            url = "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt";
            description = "WindowsSpyBlocker telemetry";
          }
          {
            url = "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt";
            description = "Frogeye First-party trackers";
          }
        ];
        settings = {
          dhcp.active = false;
          dns = {
            cnameRecords = [];
            domain = domain;
            domainNeeded = true;
            listeningMode = "ALL";
            expandHosts = true;
            interface = "all";
            hosts =
              [
                "${featureCall.unifiedDNS.gateway} gateway"
                "${currentIP} pi-hole"
                "${currentIP} ${domain}"
                "${featureCall.unifiedDNS.tailscaleIP} ${domain}"
              ]
              ++ (mkDnsRecords currentIP)
              ++ (mkDnsRecords featureCall.unifiedDNS.tailscaleIP);
            upstreams = [
              "94.140.14.14"
              "1.1.1.1"
            ];
          };
          ntp = {
            ipv4.active = false;
            ipv6.active = false;
            sync.active = false;
          };
          webserver.api.cli_pw = true;
          webserver.api.pwhash = "";
          session.timeout = 43200;
        };
      };

      pihole-web = {
        enable = true;
        ports = [8081];
      };

      nginx = {
        enable = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
        virtualHosts =
          lib.mapAttrs' (
            name: svc:
              lib.nameValuePair "${name}.${domain}" {
                useACMEHost = domain;
                forceSSL = true;
                extraConfig = featureCall.unifiedDNS.accessControl;
                locations."/" = {
                  proxyPass = "http://127.0.0.1:${toString (portOf svc)}";
                  proxyWebsockets = true;
                };
              }
          )
          featureCall.unifiedDNS.proxyServices;
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = featureCall.unifiedDNS.email;
      certs."${domain}" = {
        inherit domain;
        extraDomainNames = ["*.${domain}"];
        dnsProvider = "hetzner";
        environmentFile = config.sops.secrets."hetzner/api".path;
        dnsResolver = "1.1.1.1:53";
        dnsPropagationCheck = true;
        group = "nginx";
        webroot = null;
      };
    };

    features.preservation.system.directories = ["/etc/pihole"];

    features.unifiedDNS.proxyServices.pi-hole = {
      port = 8081;
      icon = "si-pihole";
      description = "DNS ad-blocker and DHCP server";
    };
  };
}
