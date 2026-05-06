{
  config,
  lib,
  ...
}:

let
  cfg = config.optionals.features.qbit;
  user = config.core.user;
  domain = "moontier.online";
  currentIP = "192.168.1.106";

in

{
  options.optionals.features.qbit.enable = lib.mkOption {
    type = lib.types.bool;
    description = "qbit Configuration";
    default = false;
  };
  config = lib.mkIf cfg.enable {

    core.features.mediaPermissions.enable = true;
    sops.secrets."qui/secret" = {
      group = "media";
    };

    optionals.features.nginx.proxyServices.qui = 3000;

    services = {
      qui = {
        secretFile = config.sops.secrets."qui/secret".path;
        openFirewall = true;
        group = "media";
        enable = true;
        settings = {
          port = 3000; # Just to make sure.
          host = "0.0.0.0";
          # baseUrl = "/qui";
        };
      };
      qbittorrent = {
        enable = true;
        openFirewall = true;
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
    optionals.features.nginx.proxyServices.qbit = 8080;
  };
}
