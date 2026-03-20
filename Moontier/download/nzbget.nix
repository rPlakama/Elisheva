{ ... }:
{

  systemd.services.nzbget.serviceConfig.LimitNOFILE = 65536;
  services.nzbget = {
    enable = true;
    group = "media";
  };

  networking.firewall.allowedTCPPorts = [ 6789 ];
}
