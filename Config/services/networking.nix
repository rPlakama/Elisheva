{ ... }:
{
  networking.firewall = {
    enable = true;
  };
  services = {
    resolved.enable = true;
    syncthing = {
      enable = true;
    };
  };

  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];
}
