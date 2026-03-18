{ ... }:

{
  services = {
    bazarr = {
      enable = true;
      group = "media";
      openFirewall = true;
    };

    flaresolverr = {
      enable = true;
      openFirewall = true;
      port = 8191;
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
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      lidarr-unstable = {
        image = "lscr.io/linuxserver/lidarr:nightly";
        autoStart = true;
        environment = {
          PUID = "1000";
          PGID = "1001";
          TZ = "America/Recife";
        };
        volumes = [
          "/var/lib/lidarr:/config"
          "/media:/media"
        ];
        ports = [ "8686:8686" ];
      };
    };
  };
}
