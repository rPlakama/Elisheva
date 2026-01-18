{ ... }:
{
  networking = {
    firewall.allowedUDPPorts = [
      41641
    ];
    firewall.allowedTCPPorts = [
      80
      443
      8085
      8096
      5030
      58846
      9091
    ];
  };
}
