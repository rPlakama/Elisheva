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
  theming = featureCall.theming;
  delayMs = 500;
  user = config.core.user;
  nCallPanel = "noctalia msg panel-toggle";

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

      programs.umbriel.enable = true;

      hjem.users.${user}.programs.umbriel = {
        enable = true;

        settings = {
          include.files = [ "noctalia.toml" ];
          general = {
            xwayland = true;
            show_cheatsheet = true;
            focus_on_activate = false;
          };

          appearance = {
            corner_radius = 0;
            prefer_no_csd = true;
            border_width = 2;
            animation_ms = 200;

            shadow = {
              enabled = true;
              softness = 15;
            };
          };

          workspaces = {
            back_and_forth = true;
          };

          overview = {
            zoom = 0.5;
            background_tint = "#10080808";
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
            middle_click_paste = false;

            touchpad = {
              tap = true;
              natural_scroll = true;
            };

            keyboard = {
              layout = keyboardLayout;
              options = "caps:swapescape";
              repeat_rate = 25;
              repeat_delay = 600;
            };

            focus = {
              follows_mouse = false;
            };

            cursor = {
              theme = theming.cursorTheme;
              size = theming.cursorSize;
            };
          };

          hot_corners = {
            top_left = {
              enabled = true;
              action = "overview-open";
              delay_ms = delayMs;
            };
          };

          keybinds = {
            "Mod+Return" = "spawn:foot";
            "Mod+W" = "window-close";
            "Mod+R" = "window-cycle-width";

            "Mod+H" = "window-focus-left";
            "Mod+J" = "window-focus-down";
            "Mod+K" = "window-focus-up";
            "Mod+L" = "window-focus-right";

            "Mod+Shift+H" = "column-move-left";
            "Mod+Shift+L" = "column-move-right";
            "Mod+Shift+J" = "window-move-down";
            "Mod+Shift+K" = "window-move-up";

            "Mod+Ctrl+H" = "window-consume-left";
            "Mod+Ctrl+L" = "window-expel-right";

            "Mod+F" = "window-toggle-maximize";
            "Mod+Shift+F" = "window-toggle-fullscreen";
            "Mod+T" = "window-toggle-floating";

            "Mod+1" = "workspace-switch:1";
            "Mod+2" = "workspace-switch:2";
            "Mod+3" = "workspace-switch:3";
            "Mod+4" = "workspace-switch:4";
            "Mod+5" = "workspace-switch:5";
            "Mod+6" = "workspace-switch:6";
            "Mod+7" = "workspace-switch:7";
            "Mod+8" = "workspace-switch:8";
            "Mod+9" = "workspace-switch:9";
            "Mod+0" = "workspace-switch:10";

            "Mod+Shift+1" = "window-move-to-workspace:1";
            "Mod+Shift+2" = "window-move-to-workspace:2";
            "Mod+Shift+3" = "window-move-to-workspace:3";
            "Mod+Shift+4" = "window-move-to-workspace:4";
            "Mod+Shift+5" = "window-move-to-workspace:5";
            "Mod+Shift+6" = "window-move-to-workspace:6";
            "Mod+Shift+7" = "window-move-to-workspace:7";
            "Mod+Shift+8" = "window-move-to-workspace:8";
            "Mod+Shift+9" = "window-move-to-workspace:9";
            "Mod+Shift+0" = "window-move-to-workspace:10";

            "Mod+Comma" = "window-move-to-workspace-previous";
            "Mod+Period" = "window-move-to-workspace-next";

            "Mod+WheelUp" = "window-focus-left";
            "Mod+WheelDown" = "window-focus-right";
            "Mod+Shift+WheelUp" = "column-move-left";
            "Mod+Shift+WheelDown" = "column-move-right";

            "Mod+Tab" = "overview-toggle";

            "XF86AudioRaiseVolume" = "spawn:wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
            "XF86AudioLowerVolume" = "spawn:wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
            "XF86AudioMute" = "spawn:wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            "XF86AudioPlay" = "spawn:playerctl play-pause";
            "XF86AudioNext" = "spawn:playerctl next";
            "XF86AudioPrev" = "spawn:playerctl previous";
          };
        };
      };
    })

    (mkIf (featureCall.noctalia.enable) {

      hjem.users.${user}.programs.umbriel.settings = {
        general.autostart = [ "noctalia" ];
        keybinds = {
          "Mod+Space" = "spawn:${nCallPanel} launcher";
          "Mod+V" = "spawn:${nCallPanel} clipboard";
          "Ctrl+Alt+A" = "spawn:${nCallPanel} control-center";
          "Ctrl+Alt+S" = "spawn:${nCallPanel} session";
          "Ctrl+Alt+W" = "spawn:${nCallPanel} wallpaper";
          "Ctrl+Alt+D" = "spawn:noctalia msg wallpaper-random";
          "XF86MonBrightnessUp" = "spawn:noctalia msg brightness-up";
          "XF86MonBrightnessDown" = "spawn:noctalia msg brightness-down";
        };

        hot_corners.bottom_right = {
          enabled = true;
          delay_ms = 500;
          action = "spawn:${nCallPanel} launcher";
        };

      };
    })
  ];
}
