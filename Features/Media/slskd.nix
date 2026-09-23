{
  lib,
  config,
  pkgsM,
  ...
}:
let
  featureCall = config.features;
  slskdPort = 5030;
  slskdListenPort = 50000;
  secret = config.sops.placeholder;
in
{
  options.features.slskd.enable = lib.mkEnableOption "Soulseek client";

  config = lib.mkIf featureCall.slskd.enable {
    sops = {
      secrets = {
        "slskd/username" = { };
        "slskd/password" = { };
        "slskd/web-username" = { };
        "slskd/web-password" = { };
        "slskd/api-main" = { };
      };
      templates."slskd.env".content = ''
        SLSKD_SLSK_USERNAME=${secret."slskd/username"}
        SLSKD_SLSK_PASSWORD=${secret."slskd/password"}
        SLSKD_USERNAME=${secret."slskd/web-username"}
        SLSKD_PASSWORD=${secret."slskd/web-password"}
        SLSKD_API_KEY=${secret."slskd/api-main"}
      '';
    };

    features = {
      mediaPermissions.enable = true;
      preservation.system.directories = [ "/var/lib/slskd" ];
      unifiedDNS.proxyServices.slskd = {
        port = slskdPort;
        icon = "sh-slskd";
        description = "Soulseek music sharing client";
      };
    };

    networking.firewall.allowedTCPPorts = [ slskdListenPort ];

    services.slskd = {
      enable = true;
      group = "media";
      package = pkgsM.slskd;
      environmentFile = config.sops.templates."slskd.env".path;

      settings = {
        web = {
          address = "0.0.0.0";
          port = slskdPort;
          url_base = "/slskd";
        };
        shares.directories = [
          "/media/music"
          "!/media/music/downloads"
        ];
        directories.downloads = "/media/music/library";
        soulseek.listen_port = slskdListenPort;
      };
    };
  };
}
