{ config, ... }:

{

  sops = {
    secrets."slskd/username" = { };
    secrets."slskd/password" = { };

    templates."slskd.env".content = ''
      SLSKD_SLSK_USERNAME=${config.sops.placeholder."slskd/username"}
      SLSKD_SLSK_PASSWORD=${config.sops.placeholder."slskd/password"}
    '';
  };
  networking.firewall.allowedTCPPorts = [ 6789 ]; # <-- nzbget port
  services = {
    nzbget = {
      enable = true;
      group = "media";
    };
    deluge = {
      enable = true;
      web = {
        enable = true;
        openFirewall = true;
        port = 8112;
      };
      openFirewall = true;
      group = "media";
    };

    slskd = {
      enable = true;
      domain = "slskd.placeholder.com";
      group = "media";

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
