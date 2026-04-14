{ lib, config, ... }:

let
  cfg = config.optionals.features.slskd;
in
{
  options.optionals.features.slskd.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Slskd, a morden Soulseek client.";
    default = false;
  };
  config = lib.mkIf cfg.enable {
    core.features.MediaPermissions.enable = true;
    sops = {
      secrets."slskd/username" = { };
      secrets."slskd/password" = { };

      templates."slskd.env".content = ''
        SLSKD_SLSK_USERNAME=${config.sops.placeholder."slskd/username"}
        SLSKD_SLSK_PASSWORD=${config.sops.placeholder."slskd/password"}
      '';
    };
    slskd = {
      enable = true;
      domain = null;
      group = "media";

      environmentFile = config.sops.templates."slskd.env".path;

      settings = {
        soulseek = {
          listen_port = 50000;
          upnp = true;
        };
        shares = {
          directories = [ "/media/music" ];
          filters = [
            "Thumbs.db"
            "Desktop.ini"
            ".DS_Store"
          ];
        };
        directories = {
          downloads = "/media/music/library";
          incomplete = "/media/music/downloads";
        };
        web = {
          address = "0.0.0.0";
          port = 5030;
        };
      };
    };
  };
}
