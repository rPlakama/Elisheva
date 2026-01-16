{ ... }:
{
  networking = {
    firewall.allowedUDPPorts = [ 41641 ];
    firewall.allowedTCPPorts = [
      80
      443
      8085
      8096
      5030
      # Torrent
      58846
      9091
    ];
  };
  services = {
    nginx.virtualHosts."dashboard.moontier.lan" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 8085;
        }
      ];
    };
  };
}
