{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf types;
  inherit (types) str bool int;

  cfg = config.features.theming;
  user = config.core.user;
  headless = config.core.headless;

  gtkSettings = ''
    [Settings]
    gtk-cursor-theme-name=${cfg.cursorTheme}
    gtk-cursor-theme-size=${toString cfg.cursorSize}
    gtk-font-name=${cfg.fontFamily},  ${toString cfg.fontSize}
    gtk-icon-theme-name=${cfg.iconTheme}
    gtk-application-prefer-dark-theme=${if cfg.darkTheme then "1" else "0"}
  '';
in
{
  options.features.theming = {
    enable = mkOption {
      type = bool;
      default = !headless;
      description = "Centralized theming";
    };

    cursorTheme = mkOption {
      type = str;
      default = "volantes_light_cursors";
      description = "Cursor theme name for the compositor";
    };
    cursorSize = mkOption {
      type = int;
      default = 24;
      description = "Cursor size in pixels";
    };
    iconTheme = mkOption {
      type = str;
      default = "Papirus-Dark";
      description = "Icon theme name";
    };
    fontFamily = mkOption {
      type = str;
      default = "Montserrat Medium";
      description = "UI / sans-serif font family";
    };
    fontSize = mkOption {
      type = int;
      default = 10;
      description = "UI font size (pt, used by GTK)";
    };
    monoFont = mkOption {
      type = str;
      default = "CaskaydiaCove Nerd Font Mono";
      description = "Monospace / terminal font family";
    };
    monoFontSize = mkOption {
      type = int;
      default = 9;
      description = "Monospace font size";
    };
    darkTheme = mkOption {
      type = bool;
      default = true;
      description = "Prefer dark theme; propagates to noctalia GTK templates";
    };
    base16Theme = mkOption {
      type = str;
      default = "chalk";
      description = "base16 colorscheme name for Neovim";
    };
  };

  config = mkIf cfg.enable {
    fonts.packages = with pkgs; [
      nerd-fonts.caskaydia-cove
      montserrat
      arkpandora_ttf
    ];

    environment.systemPackages = with pkgs; [
      volantes-cursors
      papirus-icon-theme
      papirus-folders
    ];

    environment.sessionVariables.GTK_ICON_THEME_NAME = cfg.iconTheme;

    hjem.users.${user} = {
      files.".config/gtk-3.0/settings.ini".text = gtkSettings;
      files.".config/gtk-4.0/settings.ini".text = gtkSettings;
    };

    features = {
      graphicalPkgs.foot.font = "${cfg.monoFont}:size=${toString (cfg.monoFontSize)}";
      niri.cursorTheme = cfg.cursorTheme;
      niri.cursorSize = cfg.cursorSize;
      noctalia.fontFamily = cfg.fontFamily;
      noctalia.darkMode = cfg.darkTheme;
    };
    programs.nixvim.colorschemes.base16 = {
      enable = true;
      colorscheme = cfg.base16Theme;
    };
  };
}
