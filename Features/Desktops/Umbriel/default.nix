{
  inputs,
  config,
  lib,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    types
    mkIf
    optionals
    ;
  inherit (types) bool;

  keyboardLayout = config.core.keyboardLayout;
  featureCall = config.features;
  delayMs = 500;

in
{

  options.features.umbriel = {
    enable = mkEnableOption "Umbriel Configuration";
    type = bool;
  };

  config = mkIf featureCall.umbriel.enable {

    imports = [
      inputs.umbriel.nixosModules.default
    ]
    ++ optionals (featureCall.noctalia) [
      ./noctalia-binds.nix
    ];

    hjem = {
      extraModules = [
        inputs.umbriel.hjemModules.default
      ];
    };

    programs.umbriel = {
      enable = true;

      appearance = {

        shadow = {
          enabled = true;
          softness = 15;
          spread = 10;
        };
      };

      settings = {
        overview = {
          background = "#10080808";
        };

        general = {
          autostart = [ "noctalia" ];
          xwayland = true;
        };

        layout = {
          gap = 5;
          mode = "scrolling";
          width_presets = [
            0.333
            0.5
            0.667
          ];
        };

        input = {

          touchpad = {
            tap = true;
            natural_scroll = true;
            accel_profile = "adaptive";
          };

          keyboard = {
            layout = keyboardLayout;
            options = "caps:swapescape";
          };
        };

        hot_corners = {
          top_left = {
            enable = true;
            action = "overview-open";
            delay_ms = delayMs;
          };
        };

        keybinds = {
          "Mod+Return" = "spawn:foot"; # Shall be var
          "Mod+W" = "window-close";
        };
      };
    };
  };
}
