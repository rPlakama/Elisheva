{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.features.qbit;
  user = config.core.user;
in {
  options.features.qbit.enable = lib.mkEnableOption "qBittorrent + Qui";
  config = lib.mkIf cfg.enable {
    features.mediaPermissions.enable = true;
    sops.secrets."qui/secret" = {
      group = "media";
    };

    features = {
      preservation.system.directories = [
        "/var/lib/qbittorrent"
        "/var/lib/qui"
      ];
      unifiedDNS.proxyServices = {
        qui = 3000;
        qbit = 8080;
      };
    };

    environment.systemPackages = lib.optionals config.features.graphicalPkgs.enable (
      with pkgs; [
        qbittorrent
      ]
    );
    services = {
      qui = {
        secretFile = config.sops.secrets."qui/secret".path;
        group = "media";
        enable = !(config.features.graphicalPkgs.enable);
        settings = {
          port = 3000;
          host = "0.0.0.0";
        };
      };
      qbittorrent = {
        enable = true;
        group = "media";
        serverConfig = {
          LegalNotice.Accepted = true;
          Preferences = {
            Queueing = {
              QueueingEnabled = false;
            };
            WebUI = {
              Username = "${user}";
              Password_PBKDF2 = "@ByteArray(ttJDfjqsdk8ccksmlOI15A==:/WoWQEN+/ObzbkNCDVVZ4/3yfxkTXz58jXYvxYmHXWayB0VHghFapn+RFJZOFZyNcpcsaOUWW2+QtgAkwzJwFQ==)";
            };
            "General.Locale" = "en";
          };
        };
      };
    };
  };
}
