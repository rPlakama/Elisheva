{ ... }:

{
  services.deluge = {
    enable = true;
    web = {
      enable = true;
      openFirewall = true;
      port = 8112;
    };
    openFirewall = true;
    group = "users";
  };

  systemd.services.deluged.serviceConfig.ReadWritePaths = [ "/mnt/@media" ];
}
