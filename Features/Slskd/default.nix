{ lib, config, ... }:

let
  cfg = config.optionals.features.slskd;
in
{
  options.optionals.features.slskd.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Slskd, a modern Soulseek client.";
    default = false;
  };

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
      core.features.mediaPermissions.enable = true;
      optionals.features.nginx.proxyServices.slskd = 5030;
      services.slskd = {
        enable = true;
        group = "media";
        environmentFile = config.sops.templates."slskd.env".path;

        settings = {
          soulseek = {
            listen_port = 50000;
            upnp = true;
          };
          shares.directories = [ "/media/music" ];
          directories = {
            downloads = "/media/music/library";
            incomplete = "/media/music/downloads";
          };
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
