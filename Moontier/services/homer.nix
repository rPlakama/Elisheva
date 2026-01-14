{ ... }:
{
  services.homer = {
    virtualHost.domain = "dashboard.moontier.lan";
    virtualHost.nginx.enable = true;
    enable = true;

    settings = {
      title = "Home Lab";
      icon = "fas fa-server";

      services = [
        {
          name = "Media";
          icon = "fas fa-film";
          items = [
            {
              name = "Jellyfin";
              logo = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/jellyfin.png";
              url = "http://192.168.0.9:8096";
              subtitle = "Movies & TV Shows";
              target = "_blank";
            }
          ];
        }
        {
          name = "Downloaders";
          icon = "fas fa-film";
          items = [
            {
              name = "Slskd";
              logo = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/slskd.svg";
              url = "http://192.168.0.9:5030";
              subtitle = "Music Downloader";
              target = "_blank";
            }
            {
              name = "Transmission";
              logo = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/transmission.png";
              url = "http://192.168.0.9:9091";
              subtitle = "Torrent Client";
            }
          ];
        }

      ];

    };
  };
}
