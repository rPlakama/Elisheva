{ ... }:
{
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "zt+" ];
    allowedTCPPorts = [ 25565 ];
    allowedUDPPorts = [ 25565 ];
  };
  services.zerotierone.enable = true;
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];
}
