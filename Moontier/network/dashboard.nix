{
  config,
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

    templates."homepage.env" = {
      content = ''
        HOMEPAGE_VAR_RADARR=${config.sops.placeholder."dashboard/radarr_apikey"}
        HOMEPAGE_VAR_SONARR=${config.sops.placeholder."dashboard/sonarr_apikey"}
        HOMEPAGE_VAR_LIDARR=${config.sops.placeholder."dashboard/lidarr_apikey"}
        HOMEPAGE_VAR_PROWLARR=${config.sops.placeholder."dashboard/prowlarr_apikey"}
        HOMEPAGE_VAR_SLSKD=${config.sops.placeholder."dashboard/slskd_apikey"}
        HOMEPAGE_VAR_JELLYFIN=${config.sops.placeholder."dashboard/jellyfin_apikey"}
        HOMEPAGE_VAR_JELLYSEERR=${config.sops.placeholder."dashboard/jellyseerr_apikey"}
      '';
      owner = "root";
      group = "users";
      mode = "0440";
    };
  };

  services.homepage-dashboard = {
    enable = true;
    listenPort = 8082;
    openFirewall = true;
    allowedHosts = "*";
    customCSS = builtins.readFile ./style.css;
    environmentFile = config.sops.templates."homepage.env".path;

    settings = {
      title = "Moontier";
      layout = {
        "Main" = {
          style = "row";
          columns = 2;
        };
      };
    };

    services = [
      {
        "Main" = [
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
          # 3. Managers
          {
            "Sonarr" = {
              href = "${myServerIP}:8989";
              icon = "sonarr.png";
              description = "TV Shows";
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
              description = "Movies";
              widget = {
                type = "radarr";
                url = "http://127.0.0.1:7878";
                key = "{{HOMEPAGE_VAR_RADARR}}";
              };
            };
          }
          {
            "Lidarr" = {
              href = "${myServerIP}:8686";
              icon = "lidarr.png";
              description = "Music";
              widget = {
                type = "lidarr";
                url = "http://127.0.0.1:8686";
                key = "{{HOMEPAGE_VAR_LIDARR}}";
              };
            };
          }
          {
            "Prowlarr" = {
              href = "${myServerIP}:9696";
              icon = "prowlarr.png";
              description = "Indexers";
              widget = {
                type = "prowlarr";
                url = "http://127.0.0.1:9696";
                key = "{{HOMEPAGE_VAR_PROWLARR}}";
              };
            };
          }
          # 4. Downloaders
          {
            "Jellyseerr" = {
              href = "${myServerIP}:5055";
              icon = "jellyseerr.png";
              description = "Requests";
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
              description = "Torrents";
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
              description = "Soulseek";
              widget = {
                type = "slskd";
                url = "http://127.0.0.1:5030";
                key = "{{HOMEPAGE_VAR_SLSKD}}";
              };
            };
          }
        ];
      }
    ];
  };
}
