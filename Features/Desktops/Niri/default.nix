{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.features.niri;
  user = config.core.user;
in
{

  options.features.niri = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Niri Configuration";
    };
    ppd = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Allow ppd";
      };
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

    # XDG_CURRENT_DESKTOP=GNOME gnome-control-center online-accounts --> Might be useful.
    services.gnome.gnome-online-accounts.enable = true;

    hjem.users.${user} = {
      files.".config/niri/config.kdl".text =
        builtins.replaceStrings
          [ "@ImportDMS@" "@ImportNoctalia@" "@keyboardLayout@" "@Variant@" ]
          [ cfg.importDMS cfg.ImportNoctalia cfg.keyboardLayout cfg.VariantKB ]
          (builtins.readFile ./config.kdl);
    };
  };
}
