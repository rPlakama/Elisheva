{ ... }:
let
  myServerIP = "http://Moontier.local";
in
{
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };
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
              name = "Transmission";
              logo = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/transmission.png";
              url = "${myServerIP}:9091";
              subtitle = "Torrent Client";
            }
          ];
        }

      ];

    };
  };
}
