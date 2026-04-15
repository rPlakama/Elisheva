{
  config,
  lib,
  ...
}:

let
  cfg = config.optionals.features.qbit;
  user = config.core.user;

in

{
  options.optionals.features.qbit.enable = lib.mkOption {
    type = lib.types.bool;
    description = "qbit Configuration";
    default = false;
  };
  config = lib.mkIf cfg.enable {

    core.features.mediaPermissions.enable = true;
    services.qbittorrent = {
      enable = true;
      openFirewall = true;
      group = "media";
      serverConfig = {
        LegalNotice.Accepted = true;
        BitTorrent = {
          "Session.MaxActiveDownloads" = 15;
          "Session.MaxActiveUploads" = 500;
          "Session.MaxActiveTorrents" = 500;
          "Session.QueueingSystemEnabled" = true;
        };
        Preferences = {
          WebUI = {
            Username = "${user}";
            Password_PBKDF2 = "@ByteArray(ttJDfjqsdk8ccksmlOI15A==:/WoWQEN+/ObzbkNCDVVZ4/3yfxkTXz58jXYvxYmHXWayB0VHghFapn+RFJZOFZyNcpcsaOUWW2+QtgAkwzJwFQ==)";
          };
          "General.Locale" = "en";
          "Downloads.SavePath" = "/media/downloads";
        };
      };
    };
  };
}
