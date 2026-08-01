{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    types
    optionalString
    ;
  inherit (types) str;

  cfg = config.features.niri;
  theming = config.features.theming;

  powerProfileBind = optionalString config.core.isLaptop ''
    "Ctrl+Alt+Q" {
        spawn "sh" "-c" "current=$(powerprofilesctl get); case $current in performance) next=balanced ;; balanced) next=power-saver ;; power-saver) next=performance ;; esac; powerprofilesctl set $next;"
    }
  '';

  cursorBlock = ''
    cursor {
        xcursor-theme "${theming.cursorTheme}"
        xcursor-size ${toString theming.cursorSize}
    }
  '';

  outputBlock = ''
            output "${cfg.output.monitor}" {
            ${optionalString cfg.output.vrr.enable "    variable-refresh-rate"}
    				}
        		'';
in
{
  options.features.niri = {
    enable = mkEnableOption "Niri Configuration";
    VariantKB = mkOption {
      type = str;
      default = "";
      description = "Keyboard Variant";
    };
    noctalia = {
      import = mkOption {
        type = str;
        default = "";
        description = "Additional KDL if Noctalia is added";
      };
      enabled = mkEnableOption "Noctalia integration";
    };
    keyboardLayout = mkOption {
      type = str;
      default = "br";
      description = "Keyboard layout";
    };
    output = {
      monitor = mkOption {
        type = str;
        default = "eDP-1";
        description = "Monitor output name";
      };
      vrr.enable = mkEnableOption "Variable Refresh Rate (Adaptive Sync) on monitors that support it";
    };
  };

  config = mkIf cfg.enable {
    programs.niri.enable = true;

    environment.systemPackages = with pkgs; [
      nautilus
      loupe
      xwayland-satellite
      libnotify
      wl-clipboard
      pulseaudio
    ];

    hjem.users.${config.core.user}.files.".config/niri/config.kdl".text =
      builtins.replaceStrings
        [ "@ImportNoctalia@" "@cursor@" "@keyboardLayout@" "@Variant@" "@powerProfileBind@" "@output@" ]
        [ cfg.noctalia.import cursorBlock cfg.keyboardLayout cfg.VariantKB powerProfileBind outputBlock ]
        (builtins.readFile ./config.kdl);
  };
}
