{ ... }:

{
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

    jellyseerr = {
      enable = true;
      openFirewall = true;
    };

    lidarr = {
      enable = true;
      group = "users";
      openFirewall = true;
    };

    prowlarr = {
      enable = true;
      openFirewall = true;
    };

    radarr = {
      enable = true;
      group = "users";
      openFirewall = true;
    };

    readarr = {
      enable = true;
    };

    sonarr = {
      enable = true;
      group = "users";
      openFirewall = true;
    };
  };
}
