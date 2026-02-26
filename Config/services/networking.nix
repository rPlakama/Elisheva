{ ... }:
{
  networking.firewall = {
    enable = true;
  };
  services = {
    resolved.enable = true;
    syncthing = {
      enable = true;
      user = "rplakama";
      dataDir = "/home/rplakama";
      configDir = "/home/rplakama/.config/syncthing";
      openDefaultPorts = true;
    };
  };

  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];
}
