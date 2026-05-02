{
  config,
  lib,
  ...
}:

let
  domain = "moontier.online";
  currentIP = "192.168.1.106";
in
{
  options.optionals.features.readingStack.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Tools and Services for Personal Bookshelf";
  };

  config = lib.mkMerge [
    {
      sops.secrets."kavita/token" = { };
    }

    (lib.mkIf config.optionals.features.readingStack.enable {
      core.features.mediaPermissions.enable = true;

      networking.firewall.allowedTCPPorts = [
        3034
      ];

      services.calibre-web = {
        enable = true;
        openFirewall = true;
        group = "media";
        listen.port = 8083;
        options = {
          enableBookConversion = true;
          calibreLibrary = "/media/calibre";
        };
      };

      systemd.services.kavita.serviceConfig.SupplementaryGroups = [ "media" ];

      services.kavita = {
        enable = true;
        settings = {
          Port = 3034;
          baseUrl = "/kavita/";
        };
        tokenKeyFile = config.sops.secrets."kavita/token".path;
      };

      services.nginx.virtualHosts."${domain}".locations = {
        # Metadata Handler:
        "^~ /calibre-web/" = {
          proxyPass = "http://${currentIP}:8083/";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header X-Script-Name /calibre-web;
          '';
        };

        # Reader itself
        "^~ /kavita/" = {
          proxyPass = "http://127.0.0.1:3034";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            aio threads;
          '';
        };
      };
    })
  ];
}
