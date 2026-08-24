{
  inputs,
  config,
  lib,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    ;

  keyboardLayout = config.core.keyboardLayout;
  featureCall = config.features;
  delayMs = 500;
  user = config.core.user;

in
{

  options.features.umbriel.enable = mkEnableOption "Umbriel Configuration";

  imports = [
    inputs.umbriel.nixosModules.default
  ];

  config = mkMerge [

    (mkIf (featureCall.umbriel.enable) {

      hjem.extraModules = [
        inputs.umbriel.hjemModules.default
      ];

      hjem.users.${user}.programs.umbriel = {
        enable = true;

        settings = {
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
    })

    (mkIf (featureCall.noctalia.enable) {

    })

  ];
}
