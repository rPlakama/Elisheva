{ ... }:
let
  myServerIP = "http://moontier";
in
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
              url = "${myServerIP}:8096";
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
              url = "${myServerIP}:5030";
              subtitle = "Music Downloader";
              target = "_blank";
            }
            {
              name = "Deluge";
              logo = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/deluge.png";
              url = "${myServerIP}:9091";
              subtitle = "Torrent Client";
            }
          ];
        }
        {
          name = "Management";
          icon = "fas fa-tools";
          items = [
            {
              name = "Prowlarr";
              logo = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/prowlarr.png";
              url = "${myServerIP}:9696";
              subtitle = "Indexers";
            }
          ];
        }
      ];

    };
  };
}
