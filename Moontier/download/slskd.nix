{ config, ... }:

{
  sops = {
    secrets = {
      "slskd/username" = {
        owner = "rplakama";
      };
      "slskd/password" = {
        owner = "rplakama";
      };
    };

    templates."slskd.env" = {
      content = ''
        SLSKD_WEB__AUTHENTICATION__API_KEYS__homepage__ROLE=readonly
        SLSKD_WEB__AUTHENTICATION__API_KEYS__homepage__CIDR=0.0.0.0/0
        SLSKD_SLSK_USERNAME=${config.sops.placeholder."slskd/username"}
        SLSKD_SLSK_PASSWORD=${config.sops.placeholder."slskd/password"}
      '';
      owner = "rplakama";
      group = "users";
    };
  };

  services.slskd = {
    enable = true;
    openFirewall = true;

    group = "media";
    user = "rplakama";
    domain = "slskd.nix.com";

    environmentFile = config.sops.templates."slskd.env".path;

    settings = {
      shares = {
        directories = [ "/media/music" ];
        filters = [
          "Thumbs.db"
          "Desktop.ini"
          ".DS_Store"
        ];
      };
      web = {
        address = "0.0.0.0";
        port = 5030;
      };
      directories = {
        downloads = "/media/music/library";
        incomplete = "/media/music/downloads";
      };
      flags = {
        no_auth = true;
      };
      soulseek = {
        listen_port = 50300;
      };
    };
  };
}
