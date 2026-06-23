{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.features.niri;
  user = config.core.user;

  isLaptop = config.core.isLaptop;

  powerProfileBind = lib.optionalString isLaptop ''
    "Ctrl+Alt+Q" {
        spawn "sh" "-c" "current=$(powerprofilesctl get); case $current in performance) next=balanced ;; balanced) next=power-saver ;; power-saver) next=performance ;; esac; powerprofilesctl set $next;"
    }
  '';
in
{

  options.features.niri = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Niri Configuration";
    };
    VariantKB = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Keyboard Variant";
    };

    importDMS = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Additional KDL for DMS is added";
    };

    ImportNoctalia = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Additional KDL if Noctalia is added";
    };

    NoctaliaEnabled = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "If Noctalia is enabled";
    };

    DMSEnabled = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "If DMS is enabled";
    };

    keyboardLayout = lib.mkOption {
      type = lib.types.str;
      default = "br";
      description = "Keyboard layout";
    };
  };
  config = lib.mkIf cfg.enable {

    programs.niri.enable = true;

    environment.systemPackages = with pkgs; [

      nautilus
      loupe
      xwayland-satellite
      libnotify
      papirus-folders
      papirus-icon-theme
      volantes-cursors
      wl-clipboard
      pulseaudio

    ];

    hjem.users.${user} = {
      files.".config/niri/config.kdl".text =
        builtins.replaceStrings
          [ "@ImportDMS@" "@ImportNoctalia@" "@keyboardLayout@" "@Variant@" "@powerProfileBind@" ]
          [ cfg.importDMS cfg.ImportNoctalia cfg.keyboardLayout cfg.VariantKB powerProfileBind ]
          (builtins.readFile ./config.kdl);
    };

  };
}
