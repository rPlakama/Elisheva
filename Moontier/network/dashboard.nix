{ ... }:
let
  myServerIP = "http://moontier";
in
{

  services.glances = {
    enable = true;
    openFirewall = true;
  };

  services.homepage-dashboard = {
    enable = true;
    listenPort = 8082;
    openFirewall = true;
    allowedHosts = "*";
    customCSS = builtins.readFile ./style.css;

    settings = {
      title = "Moontier";

      widgets = [
        {
          resources = {
            cpu = true;
            memory = true;
            disk = "/";
          };
        }
      ];

      layout = {
        "Monitoring" = {
          style = "row";
          columns = 1;
        };
        "Media" = {
          style = "row";
          columns = 1;
        };
        "Downloaders" = {
          style = "row";
          columns = 1;
        };
        "Management" = {
          style = "row";
          columns = 1;
        };
      };
    };

    services = [
      {
        "Monitoring" = [
          {
            "Glances" = {
              href = "${myServerIP}:61208";
              icon = "glances.png";
              description = "System Monitor";
              widget = {
                type = "glances";
                url = "http://127.0.0.1:61208";
                metric = "cpu";
                version = 4;
              };
            };
          }
        ];
      }
      {
        "Media" = [
          {
            "Jellyfin" = {
              href = "${myServerIP}:8096";
              icon = "jellyfin.png";
              description = "Movies & TV Shows";
              widget = {
                type = "jellyfin";
                url = "${myServerIP}:8096";
                key = "d991b6579c4a4ef68838b4016013af83";
                enableBlocks = true;
              };
            };
          }
        ];
      }
      {
        "Downloaders" = [
          {
            "Deluge" = {
              href = "${myServerIP}:8112";
              icon = "deluge.png";
              description = "Torrent Client";
              widget = {
                type = "deluge";
                url = "${myServerIP}:8112";
                password = "deluge";
              };
            };
          }
          {
            "Slskd" = {
              href = "${myServerIP}:5030";
              icon = "slskd.png";
              description = "Soulseek Client";
              widget = {
                type = "slskd";
                url = "http://127.0.0.1:5030";
                key = "6434bc876f03b35431d91284403c7988aa6c0c8cccb2801456a4b70997063203";
              };
            };
          }
        ];
      }
      {
        "Management" = [
          {
            "Prowlarr" = {
              href = "${myServerIP}:9696";
              icon = "prowlarr.png";
              description = "Indexer Manager";
              widget = {
                type = "prowlarr";
                url = "http://127.0.0.1:9696";
                key = "49a9fd15105a4f02b4917252b5cf18e2";
              };
            };
          }
          {
            "FlareSolverr" = {
              href = "${myServerIP}:8191";
              icon = "flaresolverr.png";
              description = "Proxy Solver";
              widget = {
                type = "flaresolverr";
                url = "http://127.0.0.1:8191";
              };
            };
          }
          {
            "Shoko" = {
              href = "${myServerIP}:8111";
              icon = "shoko.png";
              description = "Anime Catalog";
              widget = {
                type = "shoko";
                url = "http://127.0.0.1:8111";
                key = "000c55d0-3e6c-4c92-aeae-9ef0aabe0ff6";
              };
            };
          }
        ];
      }
    ];
  };
}
