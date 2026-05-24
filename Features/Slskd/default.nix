{ lib, config, ... }:

let
  cfg = config.features.slskd;
in
{
  options.features.slskd.enable = lib.mkEnableOption "Soulseek client";

  config = lib.mkMerge [
    {
      sops.secrets."slskd/username" = { };
      sops.secrets."slskd/password" = { };

      sops.templates."slskd.env".content = ''
        SLSKD_SLSK_USERNAME=${config.sops.placeholder."slskd/username"}
        SLSKD_SLSK_PASSWORD=${config.sops.placeholder."slskd/password"}
      '';
    }

    (lib.mkIf cfg.enable {
      features.mediaPermissions.enable = true;
      features.unifiedDNS.proxyServices.slskd = 5030;
      services.slskd = {
        enable = true;
        group = "media";
        environmentFile = config.sops.templates."slskd.env".path;

        settings = {
          soulseek = {
            listen_port = 50000;
            upnp = true;
          };
          shares.directories = [
            "-/media/music/downloads"
            "/media/music"
          ];
          directories.downloads = "/media/music/library";
          web = {
            address = "0.0.0.0";
            port = 5030;
            url_base = "/slskd";
          };
        };
      };

    })
  ];
}
