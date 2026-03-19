{ ... }:
{
  networking = {
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    firewall = {
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
    };
    networkmanager.enable = true;
  };
  services = {
    tailscale = {
      enable = true;
      openFirewall = true;
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    resolved.enable = true;
    syncthing = {
      enable = true;
      user = "rplakama";
      dataDir = "/home/rplakama";
      configDir = "/home/rplakama/.config/syncthing";
      openDefaultPorts = true;
    };
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };
  };
}
