{
  config,
  lib,
  ...
}:
let
  cfg = config.optionals.features.pi-hole;
  currentIP = "192.168.1.106";
  gatewayIP = "192.168.1.1";
  tailscaleIP = "100.119.129.77";
in
{
  options.optionals.features.pi-hole.enable = lib.mkOption {
    type = lib.types.bool;
    description = "pi-hole Configuration";
    default = false;
  };
  config = lib.mkIf cfg.enable {
    optionals.features.nginx.proxyServices.pi-hole = 8081;

    networking = {
      defaultGateway = "${gatewayIP}";
      nameservers = [ "127.0.0.1" ];
      firewall = {
        trustedInterfaces = [
          "tailscale0"
        ];
        allowedTCPPorts = [
          80
          443
          8081
        ];
      };
    };
    services = {
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
      dnsmasq = {
        enable = false;
        settings = {
          dhcp-name-match = [
            "set:hostname-ignore,wpad"
            "set:hostname-ignore,localhost"
          ];
          dhcp-option = [
            "vendor:MSFT,2,1i"
            "6,${gatewayIP}06"
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
            # Bets
            url = "https://raw.githubusercontent.com/zangadoprojets/pi-hole-blocklist/main/BlockBets.txt";
            type = "block";
            enabled = true;
            description = "Block Bets - Apostas";
          }
          {
            url = "https://raw.githubusercontent.com/zangadoprojets/pi-hole-blocklist/main/PagesMalicious.txt";
            type = "block";
            enabled = true;
            description = "Pages Malicious";
          }
          # Spam
          {
            url = "https://raw.githubusercontent.com/zangadoprojets/pi-hole-blocklist/main/BlockSpam.txt";
            type = "block";
            enabled = true;
            description = "Block Spam";
          }
          # Gambling
          {
            url = "https://blocklistproject.github.io/Lists/gambling.txt";
            type = "block";
            enabled = true;
            description = "Blocklist Project - Gambling";
          }
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
            router = "${gatewayIP}";
          };
          dns = {
            cnameRecords = [ ];
            domain = "moontier.me";
            domainNeeded = true;
            listeningMode = "ALL";
            expandHosts = true;
            interface = "all";
            hosts = [
              "${gatewayIP}  gateway"
              "${currentIP}  pi-hole"
              "${currentIP}  moontier.online"
              "${currentIP}  st.moontier.online"
              "${tailscaleIP}  moontier.online"
            ];
            upstreams = [
              "127.0.0.1#5335"
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
        ports = [ 8081 ];
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
    systemd.tmpfiles.rules = [
      "f /etc/pihole/versions 0644 pihole pihole - -"
    ];
  };
}
