{ ... }:
{

  services = {
    pihole-ftl = {
      enable = true;
      settings = {
        BLOCKING_ENABLED = true;
        DNS_FQDN_REQUIRED = true;
        UPSTREAM_DNS = [
          "1.1.1.1"
          "8.8.8.8"
        ];
      };
    };
    pihole-web = {
      enable = true;
    };
  };
  networking.firewall = {
    allowedTCPPorts = [
      53
      80
    ];
    allowedUDPPorts = [
      53
      67
    ];
  };
}
