{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.features.qbit;
  user = config.core.user;
  headless = config.core.headless;
in
{
  options.features.qbit.enable = lib.mkEnableOption "qBittorrent + Qui";
  config = lib.mkIf cfg.enable {
    features.mediaPermissions.enable = headless;
    sops.secrets."qui/secret" = {
      group = lib.mkIf headless "media";
    };

    features = {
      preservation.system.directories = [
        "/var/lib/qbittorrent"
      ]
      ++ lib.optionals (!headless) [
        "/var/lib/qui"
      ];

      unifiedDNS.proxyServices = {
        qui = { port = 3000; };
        qbit = {
          port = 8080;
          icon = "si-qbittorrent";
        };
      };
    };

    environment.systemPackages = lib.optionals (!headless) (
      with pkgs;
      [
        qbittorrent
      ]
    );
    services = {
      qui = {
        secretFile = config.sops.secrets."qui/secret".path;
        group = "media";
        enable = headless;
        settings = {
          port = 3000;
          host = "0.0.0.0";
        };
      };
      qbittorrent = {
        enable = true;
        group = lib.mkIf headless "media";
        serverConfig = {
          LegalNotice.Accepted = true;
          BitTorrent.Session = {
            QueueingSystemEnabled = true;
            MaxActiveDownloads = 3;
            MaxActiveUploads = 3;
            MaxActiveTorrents = 5;
            MaxActiveCheckingTorrents = 1;
          };
          Preferences = {
            WebUI = {
              Username = "${user}";
              Password_PBKDF2 = "@ByteArray(ttJDfjqsdk8ccksmlOI15A==:/WoWQEN+/ObzbkNCDVVZ4/3yfxkTXz58jXYvxYmHXWayB0VHghFapn+RFJZOFZyNcpcsaOUWW2+QtgAkwzJwFQ==)";
            };
          };
        };
      };
    };
  };
}
