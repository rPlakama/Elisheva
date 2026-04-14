{ ... }:
{

  services = {

    upower.enable = true;
    bpftune.enable = true;
    devmon.enable = true;
    udisks2.enable = true;
    resolved.enable = true;
    networking.networkmanager.enable = true;

    tailscale = {
      enable = true;
      openFirewall = true;
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };

    scx = {
      enable = true;
      scheduler = "scx_lavd";
    };
  };
}
