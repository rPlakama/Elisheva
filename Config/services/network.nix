{ ... }:
{
  services.resolved.enable = true;
  networking = {
    firewall.allowedTCPPorts = [ 50300 ];
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

}
