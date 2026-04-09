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
  networking.firewall.allowedTCPPorts = [
    6789
    50000
  ];
  services = {
    nzbget = {
      enable = true;
      group = "media";
    };
    qbittorrent = {
      enable = true;
      openFirewall = true;
      group = "media";
      serverConfig = {
        LegalNotice.Accepted = true;
        Preferences = {
          WebUI = {
            Username = "rplakama";
            Password_PBKDF2 = "@ByteArray(ttJDfjqsdk8ccksmlOI15A==:/WoWQEN+/ObzbkNCDVVZ4/3yfxkTXz58jXYvxYmHXWayB0VHghFapn+RFJZOFZyNcpcsaOUWW2+QtgAkwzJwFQ==)";
          };
          General.Locale = "en";
          Downloads.SavePath = "/media/downloads";
        };
      };
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
