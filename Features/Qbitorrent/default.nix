{
  config,
  lib,
  ...
}:

let
  cfg = config.optionals.features.qbit;
in

{
  options.optionals.features.qbit.enable = lib.mkOption {
    type = lib.types.bool;
    description = "qbit Configuration";
    default = false;
  };
  config = lib.mkIf cfg.enable {

    core.features.mediaPermissions.enable = true;
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
  };
}
