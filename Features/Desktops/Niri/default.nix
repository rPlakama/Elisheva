{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkOption
    mkEnableOption
    mkIf
    types
    optionalString
    ;
  inherit (types) str;

  featureCall = config.features;
  user = config.core.user;
  theming = featureCall.theming;
  noctalia = featureCall.noctalia;

  power-cycle = optionalString (config.core.isLaptop.usesPPD || config.core.isLaptop.usesTunedPPD) ''
    "Ctrl+Alt+Q" { spawn-sh "noctalia msg power-cycle"; }
  '';

  cursorBlock = ''
    cursor {
        xcursor-theme "${theming.cursorTheme}"
        xcursor-size ${toString theming.cursorSize}
    }
  '';

  outputBlock = ''
        output "${featureCall.niri.output.monitor}" {
        ${optionalString featureCall.niri.output.vrr.enable "    variable-refresh-rate"}
    }
  '';
in {
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

  config = mkIf featureCall.niri.enable {
    programs.niri.enable = true;

    hjem.users.${user} = {
      packages = with pkgs; [
        xwayland-satellite
        libnotify
        wl-clipboard
        nautilus
      ];

      files.".config/niri/config.kdl".text =
        builtins.replaceStrings
        ["@ImportNoctalia@" "@cursor@" "@keyboardLayout@" "@Variant@" "@power-cycle@" "@output@"]
        [featureCall.niri.noctalia.import cursorBlock featureCall.niri.keyboardLayout featureCall.niri.VariantKB power-cycle outputBlock]
        (builtins.readFile ./config.kdl);
    };
  };
}
