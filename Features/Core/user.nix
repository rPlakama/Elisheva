{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.core;
  user = config.core.user;
in
{
  config = lib.mkIf cfg.enable {
    time.timeZone = "America/Recife";
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "pt_BR.UTF-8";
        LC_IDENTIFICATION = "pt_BR.UTF-8";
        LC_MEASUREMENT = "pt_BR.UTF-8";
        LC_MONETARY = "pt_BR.UTF-8";
        LC_NAME = "pt_BR.UTF-8";
        LC_NUMERIC = "pt_BR.UTF-8";
        LC_PAPER = "pt_BR.UTF-8";
        LC_TELEPHONE = "pt_BR.UTF-8";
        LC_TIME = "pt_BR.UTF-8";
      };
    };
    users = {
      groups.${user} = { };
      users.${user} = {
        isNormalUser = true;
        hashedPassword = "$y$j9T$qE7EkQbvME02UxqkVVJa91$qLOUcUnfU6IAaP17gkeQiAF2xVh6nPcnyp6K3b6yrK/";
        shell = pkgs.nushell;
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
