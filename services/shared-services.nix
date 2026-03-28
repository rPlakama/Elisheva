{ isElisheva, ... }:
{

  services = {

    upower.enable = true;
    bpftune.enable = true;
    devmon.enable = true;
    udisks2.enable = true;
    resolved.enable = true;

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

    syncthing = {
      enable = true;
      user = "rplakama";
      dataDir = "/home/rplakama";
      configDir = "/home/rplakama/.config/syncthing";
      openDefaultPorts = true;
    };

    scx = {
      enable = true;
      scheduler = "scx_lavd";
      extraArgs = if isElisheva then [ "--powersave" ] else [ ]; # <-- Let me sin with this extra evaluation!
    };

  };
}
