{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkEnableOption mkIf types;
  inherit (types) str bool int;

  cfg = config.features.theming;
  user = config.core.user;

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
    enable = mkEnableOption "Centralized theming";

    cursorTheme = mkOption { type = str; default = "volantes_light_cursors"; description = "Cursor theme name for the compositor"; };
    cursorSize = mkOption { type = int; default = 24; description = "Cursor size in pixels"; };
    iconTheme = mkOption { type = str; default = "papirus-dark"; description = "Icon theme name"; };
    fontFamily = mkOption { type = str; default = "CaskaydiaCove Nerd Font"; description = "UI / sans-serif font family"; };
    fontSize = mkOption { type = int; default = 10; description = "UI font size (pt, used by GTK)"; };
    monoFont = mkOption { type = str; default = "CaskaydiaCove Nerd Font Mono"; description = "Monospace / terminal font family"; };
    monoFontSize = mkOption { type = int; default = 9; description = "Monospace font size"; };
    darkTheme = mkOption { type = bool; default = true; description = "Prefer dark theme; propagates to noctalia GTK templates"; };
    base16Theme = mkOption { type = str; default = "chalk"; description = "base16 colorscheme name for Neovim"; };
  };

  config = mkIf cfg.enable {
    fonts.packages = with pkgs; [
      nerd-fonts.caskaydia-cove
      montserrat
      arkpandora_ttf
    ];

    environment.systemPackages = with pkgs; [
      volantes-cursors
      papirus-folders
    ];

    hjem.users.${user} = {
      files.".config/gtk-3.0/settings.ini".text = gtkSettings;
      files.".config/gtk-4.0/settings.ini".text = gtkSettings;
    };

    features.graphicalPkgs.foot.font = "${cfg.monoFont}:size=${toString cfg.monoFontSize}";
    features.niri.cursorTheme = cfg.cursorTheme;
    features.niri.cursorSize = cfg.cursorSize;
    features.noctalia.fontFamily = cfg.fontFamily;
    features.noctalia.darkMode = cfg.darkTheme;
    programs.nixvim.colorschemes.base16.colorscheme = cfg.base16Theme;
  };
}
