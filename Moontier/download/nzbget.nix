{ ... }:
{

  services.nzbget = {
    enable = true;
    group = "media";
  };

  networking.firewall.allowedTCPPorts = [ 6789 ];
}
