{
  pkgs,
  config,
  lib,
  ...
}:
let
  user = config.core.user;
in
{
  options.core.user = lib.mkOption {
    type = lib.types.str;
    description = "The primary user";
  };

  options.core.ip = lib.mkOption {
    type = lib.types.str;
    description = "IP";
    default = "";
  };

  options.core.domain = lib.mkOption {
    type = lib.types.str;
    description = "Domain";
    default = "";
  };

  config = lib.mkIf (user != "") {
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
