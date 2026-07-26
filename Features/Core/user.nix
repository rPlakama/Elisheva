{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.core;
  user = config.core.user;
  localeID = "pt_BR.UTF-8";
in
{
  config = lib.mkIf cfg.enable {
    time.timeZone = "America/Recife";
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "${localeID}";
        LC_IDENTIFICATION = "${localeID}";
        LC_MEASUREMENT = "${localeID}";
        LC_MONETARY = "${localeID}";
        LC_NAME = "${localeID}";
        LC_NUMERIC = "${localeID}";
        LC_PAPER = "${localeID}";
        LC_TELEPHONE = "${localeID}";
        LC_TIME = "${localeID}";
      };
    };

    users = {
      groups.${user} = { };
      users.${user} = {
        isNormalUser = true;
        hashedPassword = "$y$j9T$qE7EkQbvME02UxqkVVJa91$qLOUcUnfU6IAaP17gkeQiAF2xVh6nPcnyp6K3b6yrK/";
        shell = pkgs.fish;
        group = user;
        extraGroups = [
          "wheel"
          "video"
          "audio"
        ];
      };
    };
  };
}
