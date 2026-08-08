{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    types
    concatStrings
    ;
  inherit (types) str bool int;

  cfg = config.features.theming;
  user = config.core.user;
  headless = config.core.headless;

  # base16-chalk palette.
  palette = {
    base00 = "#151515";
    base01 = "#202020";
    base02 = "#303030";
    base03 = "#505050";
    base04 = "#b0b0b0";
    base05 = "#d0d0d0";
    base06 = "#e0e0e0";
    base07 = "#f5f5f5";
    base08 = "#fb9fb1";
    base09 = "#eda987";
    base0A = "#ddb26f";
    base0B = "#acc267";
    base0C = "#12cfc0";
    base0D = "#6fc2ef";
    base0E = "#e1a3ee";
    base0F = "#deaf8f";
  };

  colors =
    let
      stripHash = v: builtins.substring 1 6 v;
      parse = v: {
        r = lib.fromHexString (builtins.substring 1 2 v);
        g = lib.fromHexString (builtins.substring 3 2 v);
        b = lib.fromHexString (builtins.substring 5 2 v);
      };

      # convenience keys: colors.base0D-hex, colors.base0D-dec-r, ...
      variants = builtins.concatMap (name: [
        {
          name = "${name}-hex";
          value = stripHash palette.${name};
        }
        {
          name = "${name}-dec-r";
          value = (parse palette.${name}).r;
        }
        {
          name = "${name}-dec-g";
          value = (parse palette.${name}).g;
        }
        {
          name = "${name}-dec-b";
          value = (parse palette.${name}).b;
        }
      ]) (builtins.attrNames palette);
    in
    palette
    // builtins.listToAttrs variants
    // {
      withHashtag = palette;
      hex = builtins.mapAttrs (_: v: stripHash v) palette;
      dec = builtins.mapAttrs (_: v: parse v) palette;
    };

  # GTK CSS from the palette (what Stylix's gtk.css.mustache produced).
  # `accents` = { name = base-color; } rendered as define-color vars.
  gtkCss =
    let
      accent = name: base: ''
        @define-color ${name}_color #${colors."${base}-hex"};
        @define-color ${name}_bg_color #${colors."${base}-hex"};
        @define-color ${name}_fg_color #${colors.base00-hex};
      '';

      surface = name: base: ''
        @define-color ${name}_bg_color #${colors."${base}-hex"};
        @define-color ${name}_fg_color #${colors.base05-hex};
        @define-color ${name}_shade_color rgba(0, 0, 0, 0.07);
      '';
    in
    concatStrings [
      (accent "accent" "base0D")
      (accent "destructive" "base08")
      (accent "success" "base0B")
      (accent "warning" "base0E")
      (accent "error" "base08")
      ''
        @define-color window_bg_color #${colors.base00-hex};
        @define-color window_fg_color #${colors.base05-hex};
        @define-color view_bg_color #${colors.base00-hex};
        @define-color view_fg_color #${colors.base05-hex};
        @define-color headerbar_bg_color #${colors.base01-hex};
        @define-color headerbar_fg_color #${colors.base05-hex};
        @define-color headerbar_border_color rgba(${toString colors.base01-dec-r}, ${toString colors.base01-dec-g}, ${toString colors.base01-dec-b}, 0.7);
        @define-color headerbar_backdrop_color @window_bg_color;
        @define-color headerbar_shade_color rgba(0, 0, 0, 0.07);
        @define-color headerbar_darker_shade_color rgba(0, 0, 0, 0.07);
      ''
      (surface "sidebar" "base01")
      ''
        @define-color sidebar_backdrop_color @window_bg_color;
        @define-color secondary_sidebar_bg_color @sidebar_bg_color;
        @define-color secondary_sidebar_fg_color @sidebar_fg_color;
        @define-color secondary_sidebar_backdrop_color @sidebar_backdrop_color;
        @define-color secondary_sidebar_shade_color @sidebar_shade_color;
      ''
      (surface "card" "base01")
      (surface "dialog" "base01")
      (surface "popover" "base01")
      ''
        @define-color shade_color rgba(0, 0, 0, 0.07);
        @define-color scrollbar_outline_color #${colors.base02-hex};
      ''
    ];

  # Icon theme: full Papirus copy with the folder color applied declaratively.
  # papirus-folders is just symlinking the selected color's SVGs over the
  # generic names, so we replicate that in a derivation instead of a script.
  iconTheme = pkgs.runCommandLocal "papirus-${cfg.iconColor}" { } ''
    mkdir -p $out/share/icons
    cp -r ${pkgs.papirus-icon-theme}/share/icons/* $out/share/icons/
    chmod -R u+w $out/share/icons
    for size in 22x22 24x24 32x32 48x48 64x64; do
      for prefix in folder user; do
        for f in $out/share/icons/Papirus-Dark/$size/places/$prefix-${cfg.iconColor}-*.svg; do
          [ -e "$f" ] || continue
          base="''${f##*/}"
          target="$out/share/icons/Papirus-Dark/$size/places/''${base/-${cfg.iconColor}-/-}"
          ln -sf "''${base}" "$target"
        done
      done
    done
    ${pkgs.gtk3}/bin/gtk-update-icon-cache $out/share/icons/Papirus-Dark
  '';

  gtkSettings = ''
    [Settings]
    gtk-cursor-theme-name=${cfg.cursorTheme}
    gtk-cursor-theme-size=${toString cfg.cursorSize}
    gtk-font-name=${cfg.fontFamily}, ${toString cfg.fontSize}
    gtk-icon-theme-name=${cfg.iconTheme}
    gtk-theme-name=Adwaita
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
      description = "Icon theme name (gtk).";
    };
    iconColor = mkOption {
      type = str;
      default = "blue";
      description = "Papirus folder accent color.";
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

    hjem.users.${user} = {
      packages = with pkgs; [
        volantes-cursors
        iconTheme
      ];

      environment.sessionVariables.GTK_ICON_THEME_NAME = cfg.iconTheme;

      files = {
        ".config/gtk-3.0/settings.ini".text = gtkSettings;
        ".config/gtk-4.0/settings.ini".text = gtkSettings;
        ".config/gtk-3.0/gtk.css".text = gtkCss;
        ".config/gtk-4.0/gtk.css".text = gtkCss;
      };
    };
  };
}
