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
  options.core = {
    user = lib.mkOption {
      type = lib.types.str;
      description = "The primary user";
    };

    ip = lib.mkOption {
      type = lib.types.str;
      description = "IP";
      default = "";
    };

    gpu = {
      amd = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "AMD GPU (RADV/amdgpu)";
      };
      nvidia = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Nvidia GPU (nvidia/nouveau)";
      };
      intel = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Intel GPU (i915/Xe)";
      };
    };

    git = {
      email = lib.mkOption {
        type = lib.types.str;
        description = "git cfg email";
        default = "";
      };
      user = lib.mkOption {
        type = lib.types.str;
        description = "git cfg user";
        default = "";
      };
    };

    domain = lib.mkOption {
      type = lib.types.str;
      description = "Domain";
      default = "";
    };
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

    hjem.users.${user} = {
      files.".gitconfig".text = ''
        [user]
        name = ${config.core.git.user}
        email = ${config.core.git.email}
      '';
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
