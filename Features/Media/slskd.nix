{
  lib,
  config,
  pkgsM,
  ...
}:
let
  cfg = config.features.slskd;
  slskdPort = 5030;
  slskdListenPort = 50000;
in
{
  options.features.slskd.enable = lib.mkEnableOption "Soulseek client";

  config = lib.mkIf cfg.enable {

    sops = {
      secrets = {
        "slskd/username" = { };
        "slskd/password" = { };
        "slskd/web-username" = { };
        "slskd/web-password" = { };
        "slskd/api-main" = { };
      };
      templates."slskd.env".content = ''
        SLSKD_SLSK_USERNAME=${config.sops.placeholder."slskd/username"}
        SLSKD_SLSK_PASSWORD=${config.sops.placeholder."slskd/password"}
        SLSKD_USERNAME=${config.sops.placeholder."slskd/web-username"}
        SLSKD_PASSWORD=${config.sops.placeholder."slskd/web-password"}
        SLSKD_API_KEY=${config.sops.placeholder."slskd/api-main"}
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
