{ ... }:

{
  nixarr = {
    enable = true;
    mediaDir = "/media";
    radarr = {
      enable = true;
      openFirewall = true;
    };
    sonarr = {
      enable = true;
      openFirewall = true;
    };
  };
  services = {
    bazarr = {
      enable = true;
      openFirewall = true;
    };

    flaresolverr = {
      enable = true;
      openFirewall = true;
      port = 8191;
    };

    lidarr = {
      enable = true;
      openFirewall = true;
    };

    prowlarr = {
      enable = true;
      openFirewall = true;
    };

    readarr = {
      enable = true;
    };
  };
}
