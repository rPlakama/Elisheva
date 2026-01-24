{
  inputs,
  ...
}:

let
  myServerIP = "http://moontier";
in

{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    age.keyFile = "/var/lib/sops-nix/key.txt";
    age.generateKey = true;
    secrets = {
      "dashboard/radarr_apikey" = { };
      "dashboard/sonarr_apikey" = { };
      "dashboard/lidarr_apikey" = { };
      "dashboard/prowlarr_apikey" = { };
      "dashboard/slskd_apikey" = { };
      "dashboard/jellyfin_apikey" = { };
      "dashboard/jellyseerr_apikey" = { };
    };
  };

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
          columns = 2;
        };
      };
    };
    services = [
      {
        "Glances" = [
          {
            "Glances" = {
              href = "${myServerIP}:61208";
              icon = "glances.png";
              description = "System Monitor";
              widget = {
                type = "glances";
                url = "${myServerIP}:61208";
                cpu = true;
                diskUnits = "bytes";
                refreshInterval = 5000;
                pointsLimit = 15;
                memory = true;
                cputemp = true;
                disk = "/";
              };
            };
          }
          {
            "CPU Usage" = {
              widget = {
                type = "glances";
                url = "${myServerIP}:61208";
                metric = "cpu";
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
                enableBlocks = true;
                key = "{{HOMEPAGE_VAR_JELLYFIN}}";
              };
            };
          }
        ];
      }
      {
        "Downloaders" = [
          {
            "Jellyseer" = {
              href = "${myServerIP}:5055";
              icon = "jellyseerr.png";
              description = "Requester";
              widget = {
                type = "jellyseerr";
                url = "http://127.0.0.1:5055";
                key = "{{HOMEPAGE_VAR_JELLYSEERR}}";
              };
            };
          }
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
                key = "{{HOMEPAGE_VAR_SLSKD}}";
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
                key = "{{HOMEPAGE_VAR_PROWLARR}}";
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
            "Lidarr" = {
              href = "${myServerIP}:8686";
              icon = "lidarr.png";
              description = "Music Manager";
              widget = {
                type = "lidarr";
                url = "http://127.0.0.1:8686";
                key = "{{HOMEPAGE_VAR_LIDARR}}";
              };
            };
          }
          {
            "Sonarr" = {
              href = "${myServerIP}:8989";
              icon = "sonarr.png";
              description = "General Shows Manager";
              widget = {
                type = "sonarr";
                url = "http://127.0.0.1:8989";
                key = "{{HOMEPAGE_VAR_SONARR}}";
              };
            };
          }
          {
            "Radarr" = {
              href = "${myServerIP}:7878";
              icon = "radarr.png";
              description = "General Movie Manager";
              widget = {
                type = "radarr";
                url = "http://127.0.0.1:7878";
                #key = config.sops.secrets.
              };
            };
          }
        ];
      }
    ];
  };
}
