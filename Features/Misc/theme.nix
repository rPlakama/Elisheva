{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkIf types;
  inherit (types) str bool int;

  featureCall = config.features;
  user = config.core.user;

  strOpt = default: desc:
    mkOption {
      type = str;
      inherit default;
      description = desc;
    };
  intOpt = default: desc:
    mkOption {
      type = int;
      inherit default;
      description = desc;
    };

  inherit
    (featureCall.theming)
    iconTheme
    cursorTheme
    cursorSize
    darkTheme
    ;
  fontStr = "${featureCall.theming.fontFamily} ${toString featureCall.theming.fontSize}";

  # settings.ini —-
  gtkSettings = lib.generators.toINI {} {
    Settings = {
      gtk-theme-name = "Adwaita";
      gtk-icon-theme-name = iconTheme;
      gtk-cursor-theme-name = cursorTheme;
      gtk-cursor-theme-size = cursorSize;
      gtk-font-name = fontStr;
      gtk-application-prefer-dark-theme = darkTheme;
    };
  };

  # dconf keyfile --
  dconfKeyfile = pkgs.writeText "dconf-theming" ''
    [org/gnome/desktop/interface]
    icon-theme='${iconTheme}'
    gtk-theme='Adwaita'
    cursor-theme='${cursorTheme}'
    cursor-size=${toString cursorSize}
    font-name='${fontStr}'
    color-scheme='${
      if darkTheme
      then "prefer-dark"
      else "default"
    }'
  '';
in {
  options.features.theming = {
    enable = mkOption {
      type = bool;
      default = featureCall.niri.enable;
      description = "Enable theme";
    };

    cursorTheme = strOpt "volantes_light_cursors" "Cursor theme name for the compositor";
    cursorSize = intOpt 24 "Cursor size in pixels";
    iconTheme = strOpt "Papirus-Dark" "Icon theme name (gtk)";
    fontFamily = strOpt "Montserrat Medium" "UI / sans-serif font family";
    fontSize = intOpt 10 "UI font size (pt, used by GTK)";
    monoFont = strOpt "CaskaydiaCove Nerd Font Mono" "Monospace / terminal font family";
    monoFontSize = intOpt 9 "Monospace font size";
    base16Theme = strOpt "chalk" "base16 colorscheme name for Neovim";

    darkTheme = mkOption {
      type = bool;
      default = true;
      description = "Prefer dark theme; propagates to noctalia GTK templates";
    };
  };

  config = mkIf featureCall.theming.enable {
    programs.dconf.enable = true;

    system.activationScripts.dconfTheme.text = ''
      uid=$(${pkgs.coreutils}/bin/id -u ${user})
      bus="/run/user/$uid/bus"
      if [ -S "$bus" ]; then
        DBUS_SESSION_BUS_ADDRESS="unix:path=$bus" \
          ${pkgs.util-linux}/bin/runuser -u ${user} -- \
            ${pkgs.dconf}/bin/dconf load / < ${dconfKeyfile}
      fi
    '';

    fonts.packages = with pkgs; [
      nerd-fonts.caskaydia-cove
      montserrat
      arkpandora_ttf
    ];

    hjem.users.${user} = {
      packages = with pkgs; [
        volantes-cursors
        papirus-icon-theme
      ];

      environment.sessionVariables.GTK_ICON_THEME_NAME = iconTheme;

      files = {
        ".config/gtk-3.0/settings.ini".text = gtkSettings;
        ".config/gtk-4.0/settings.ini".text = gtkSettings;
      };
    };
  };
}
