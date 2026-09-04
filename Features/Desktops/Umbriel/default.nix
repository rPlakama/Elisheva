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
    optionalAttrs
    ;

  keyboardLayout = config.core.keyboardLayout;
  featureCall = config.features;
  theming = featureCall.theming;
  delayMs = 361;
  user = config.core.user;
  nCallPanel = "noctalia msg panel-toggle";

  power-cycle-bind =
    optionalAttrs (config.core.isLaptop.usesPPD || config.core.isLaptop.usesTunedPPD)
      {
        "Ctrl+Alt+Q" = "spawn:noctalia msg power-cycle";
      };

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

          animation = {

            beziers.softLander = [
              0.2
              1.0
              0.2
              1.0
            ];

            enabled = true;
            duration_ms = delayMs;

            windows_move = {
              enabled = true;
              duration_ms = delayMs;
              curve = "softLander";
            };

            windows_out = {
              enabled = true;
              duration_ms = delayMs;
              curve = "softLander";
            };

            overview = {
              enabled = true;
              duration_ms = delayMs;
              curve = "softLander";
            };

            windows_in = {
              enabled = true;
              duration_ms = delayMs;
              curve = "softLander";
            };
          };
          appearance = {
            corner_radius = 0;
            prefer_no_csd = true;
            border_width = 0;

            blur = {
              enabled = true;
              passes = 5;
              offset = 2.0;
              noise = 0.03;
              saturation = 1.6;
            };

            shadow = {
              enabled = true;
              softness = 10;
              spread = 1;
              offset = [
                0
                5
              ];
              color = "#00000070";
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
              0.333333
              0.666667
            ];
          };

          input = {
            middle_click_paste = false;

            touchpad = {
              tap = true;
              dwt = true;
              natural_scroll = true;
              accel_speed = 0.1;
              accel_profile = "adaptive";
              scroll_method = "two-finger";
            };

            mouse = {
              accel_speed = -0.5;
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
            "Mod+Y" = "spawn:foot -e yazi";
            "Mod+W" = "window-close";
            "Mod+R" = "window-cycle-width";
            "Mod+Shift+R" = "window-cycle-width";
            "Mod+P" =
              "spawn:sh -c 'wl-mirror $(umbriel outputs --json | jq -r .focused.name 2>/dev/null || true)'";
            "Print" = "spawn:noctalia msg screenshot-fullscreen";

            "Mod+H" = "window-focus-left";
            "Mod+J" = "window-focus-or-workspace-down";
            "Mod+K" = "window-focus-or-workspace-up";
            "Mod+L" = "window-focus-right";

            "Mod+BracketLeft" = "window-consume-left";
            "Mod+BracketRight" = "window-expel-right";

            "Mod+Ctrl+H" = "column-move-left";
            "Mod+Ctrl+L" = "column-move-right";
            "Mod+Ctrl+J" = "window-move-down";
            "Mod+Ctrl+K" = "window-move-up";

            "Mod+Shift+H" = "column-move-left";
            "Mod+Shift+L" = "column-move-right";
            "Mod+Shift+J" = "window-move-to-workspace-down";
            "Mod+Shift+K" = "window-move-to-workspace-up";

            "Mod+C" = "window-center";
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

            "XF86AudioRaiseVolume" = "spawn:wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+";
            "XF86AudioLowerVolume" = "spawn:wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-";
            "XF86AudioMute" = "spawn:wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            "XF86AudioPlay" = "spawn:playerctl play-pause";
            "XF86AudioNext" = "spawn:playerctl next";
            "XF86AudioPrev" = "spawn:playerctl previous";

            "Ctrl+Alt+M" =
              "spawn:sh -c 'echo run-shortcut:toggleMute | nc -U -w1 $XDG_RUNTIME_DIR/vesktop.sock'";
            "Ctrl+Alt+K" = "keyboard-layout-next";
          }
          // power-cycle-bind;

          window_rule = [
            {
              blur = true;
            }
            {
              match.is_focused = false;
              opacity = 0.92;
            }
            {
              match.title = "^notificationtoasts_.+_desktop";
              default_position = {
                x = 10;
                y = 10;
                anchor = "bottom_right";
              };
              default_focused = false;
              default_pinned = true;
            }
            {
              match.title = "^Picture in picture$";
              default_floating = true;
              default_size = [
                480
                270
              ];
              default_position = {
                x = 10;
                y = 10;
                anchor = "bottom_left";
              };
            }
            {
              match.app_id = "^helium$";
              match.title = "^Picture-in-Picture";
              default_floating = true;
              default_position = {
                x = 20;
                y = 20;
                anchor = "bottom_left";
              };
            }
            {
              match.app_id = "^foot$";
              match.title = "^btop-systemd-inhibit$";
              default_width = 0.6;
              default_focused = true;
            }
          ];
        };
      };
    })

    (mkIf (featureCall.noctalia.enable && featureCall.umbriel.enable) {

      hjem.users.${user}.programs.umbriel.settings = {
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
