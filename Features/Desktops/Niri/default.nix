{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.features.niri;

  powerProfileBind = lib.optionalString config.core.isLaptop ''
    "Ctrl+Alt+Q" {
        spawn "sh" "-c" "current=$(powerprofilesctl get); case $current in performance) next=balanced ;; balanced) next=power-saver ;; power-saver) next=performance ;; esac; powerprofilesctl set $next;"
    }
  '';

  outputBlock = ''
            output "${cfg.output.monitor}" {
            ${lib.optionalString cfg.output.vrr.enable "    variable-refresh-rate"}
    				}
        		'';
in
{
  options.features.niri = {
    enable = lib.mkEnableOption "Niri Configuration";
    VariantKB = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Keyboard Variant";
    };
    noctalia = {
      import = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Additional KDL if Noctalia is added";
      };
      enabled = lib.mkEnableOption "Noctalia integration";
    };
    keyboardLayout = lib.mkOption {
      type = lib.types.str;
      default = "br";
      description = "Keyboard layout";
    };
    output = {
      monitor = lib.mkOption {
        type = lib.types.str;
        default = "eDP-1";
        description = "Monitor output name";
      };
      vrr.enable = lib.mkEnableOption "Variable Refresh Rate (Adaptive Sync) on monitors that support it";
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

    hjem.users.${config.core.user}.files.".config/niri/config.kdl".text =
      builtins.replaceStrings
        [ "@ImportNoctalia@" "@keyboardLayout@" "@Variant@" "@powerProfileBind@" "@output@" ]
        [ cfg.noctalia.import cfg.keyboardLayout cfg.VariantKB powerProfileBind outputBlock ]
        (builtins.readFile ./config.kdl);
  };
}
