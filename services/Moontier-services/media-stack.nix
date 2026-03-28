{ ... }:
{
  services = {

    jellyfin = {
      enable = true;
      group = "media";
      openFirewall = true;
    };

    bazarr = {
      enable = true;
      group = "media";
      openFirewall = true;
    };

    flaresolverr = {
      enable = true;
      openFirewall = true;
    };
    prowlarr = {
      enable = true;
      openFirewall = true;
    };

    radarr = {
      enable = true;
      group = "media";
      openFirewall = true;
    };

    lidarr = {
      enable = true;
      group = "media";
      openFirewall = true;
    };

    readarr = {
      enable = true;
      group = "media";
      openFirewall = true;
    };

    sonarr = {
      enable = true;
      group = "media";
      openFirewall = true;
    };
  };
}
