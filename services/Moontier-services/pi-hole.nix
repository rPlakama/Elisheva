{ ... }:
{
  networking = {
    defaultGateway = "192.168.1.1";
    nameservers = [ "127.0.0.1" ];
  };

  services = {

    unbound = {
      enable = true;
      settings = {
        server = {
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

    dnsmasq = {
      enable = false;
      settings = {
        dhcp-name-match = [
          "set:hostname-ignore,wpad"
          "set:hostname-ignore,localhost"
        ];
        dhcp-option = [
          "vendor:MSFT,2,1i"
          "6,192.168.1.106"
        ];
        domain = [
          "moontier.me,192.168.1.0/24,local"
        ];
      };
    };

    pihole-ftl = {
      enable = true;
      lists = [
        {
          url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
          type = "block";
          enabled = true;
          description = "Steven Black's HOSTS";
        }
        {
          url = "https://big.oisd.nl";
          type = "block";
          enabled = true;
          description = "OISD Big";
        }
        {
          url = "https://v.firebog.net/hosts/Easyprivacy.txt";
          type = "block";
          enabled = true;
          description = "EasyPrivacy";
        }
      ];
      openFirewallDNS = true;
      openFirewallDHCP = true;
      openFirewallWebserver = true;
      queryLogDeleter.enable = true;
      settings = {
        dhcp = {
          active = false;
          end = "192.168.0.254";
          hosts = [ ];
          ipv6 = false;
          leaseTime = "24h";
          start = "192.168.0.61";
          rapidCommit = true;
          resolver = {
            resolveIPv6 = false;
          };
          router = "192.168.1.1";
        };
        dns = {
          cnameRecords = [ ];
          domain = "moontier.me";
          domainNeeded = true;
          listeningMode = "ALL";
          expandHosts = true;
          interface = "all";
          hosts = [
            "192.168.1.1    gateway"
            "192.168.1.1    gateway.moontier.me"
            "192.168.1.106  pi-hole"
            "192.168.1.106  pi-hole.moontier.me"
          ];
          upstreams = [
            # Cloudflare
            "127.0.0.1#5335"
            #"1.1.1.1"
            #"1.0.0.1"
          ];
        };
        ntp = {
          ipv4.active = false;
          ipv6.active = false;
          sync.active = false;
        };
        webserver = {
          api = {
            pwhash = "";
          };
          session = {
            timeout = 43200;
          };
        };
      };
      useDnsmasqConfig = true;
    };

    pihole-web = {
      enable = true;
      ports = [ 80 ];
    };

    resolved = {
      settings = {
        Resolve = {
          DNSStubListener = "no";
          MulticastDNS = "no";
        };
      };
    };
  };

  system.activationScripts = {
    print-pi-hole = {
      text = builtins.trace "building the pi-hole configuration..." "";
    };
  };

  systemd.tmpfiles.rules = [
    "f /etc/pihole/versions 0644 pihole pihole - -"
  ];
}
