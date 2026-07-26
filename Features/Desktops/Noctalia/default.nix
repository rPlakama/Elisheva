{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf types;
  inherit (types) str bool;

  user = config.core.user;
  cfg = config.features.noctalia;

  fontFamily = cfg.fontFamily;
  barRadius = 3;

  widgetsGroupOpacity = 0.0;
  widgetsGroupSpacing = 6.0;
  widgetsGroupRadius = 3.0;
in
{
  options.features.noctalia = {
    enable = mkOption {
      type = bool;
      default = config.features.niri.noctalia.enabled;
      description = "Enable Noctalia window manager environment.";
    };
    fontFamily = mkOption {
      type = str;
      default = "Montserrat Medium";
      description = "Font family used by noctalia shell and bar";
    };
    darkMode = mkOption {
      type = bool;
      default = true;
      description = "Dark mode for noctalia theme templates (GTK, etc.)";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.features.niri.enable;
        message = "noctalia requires niri";
      }
    ];

    nix.settings = {
      extra-substituters = [ "https://noctalia.cachix.org" ];
      extra-trusted-public-keys = [
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
    };
    environment.systemPackages = [
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
      pkgs.ddcutil
    ];
    services.ddccontrol.enable = true;

    features = {
      niri.noctalia.import = ''include "noctaliaBinds.kdl"'';
      graphicalPkgs.foot.theme = [
        "include=/home/${user}/.config/foot/themes/noctalia"
      ];
    };
    # Hjem block starts --
    hjem = {
      extraModules = [
        inputs.noctalia.hjemModules.default
      ];

      users.${user} = {
        files.".config/niri/noctaliaBinds.kdl".source = ./NoctaliaBinds.kdl;

        programs.noctalia = {
          enable = true;
          systemd.enable = true;
          settings = {
            shell = {
              launch_apps_as_systemd_services = true;
              corner_radius_scale = 0.25;
              font_family = fontFamily;
              niri_overview_type_to_launch_enabled = true;
              password_style = "random";
              polkit_agent = true;
              animation.speed = 0.8;
              screen_corners.size = 13;
              panel = {
                launcher_categories = true;
                session_placement = "floating";
                session_position = "center";
                transparency_mode = "soft";
                wallpaper_placement = "floating";
                wallpaper_position = "center";
              };
            };
            keybinds = {
              down = [ "Ctrl+n" ];
              left = [ "Ctrl+h" ];
              right = [ "Ctrl+l" ];
              up = [ "Ctrl+p" ];
            };
            theme = {
              source = "wallpaper";
              community_palette = "Cream Autumn";
              wallpaper_scheme = "m3-rainbow";
              mode = if cfg.darkMode then "dark" else "light";
              templates = {
                builtin_ids = [
                  "foot"
                  "gtk3"
                  "gtk4"
                  "kcolorscheme"
                  "qt"
                ];
              };
            };
            wallpaper = {
              enabled = true;
              transition_on_startup = true;
            };
            location.auto_locate = true;
            lockscreen = {
              blurred_desktop = false;
              blur_intensity = 0.65;
              tint_intensity = 0.0;
            };
            idle = {
              behavior = {
                lock = {
                  action = "lock";
                  enabled = true;
                  timeout = 600;
                };
                screen-off = {
                  action = "screen_off";
                  enabled = true;
                  timeout = 660;
                };
                lock-and-suspend = {
                  action = "lock_and_suspend";
                  enabled = true;
                  timeout = 900;
                };
              };
            };
            brightness.enable_ddcutil = true;
            bar.default = {
              margin_edge = 7;
              background_opacity = 1.0;
              font_family = fontFamily;
              position = "left";
              radius = barRadius;
              margin_ends = 105;
              capsule = false;
              capsule_radius = barRadius;
              capsule_opacity = 0.0;
              start = [ "group:g5" ];
              center = [ "group:g6" ];
              end = [
                "group:g4"
                "group:g1"
              ];
              capsule_group = [
                {
                  fill = "surface_variant";
                  id = "g1";
                  members = [
                    "bluetooth"
                    "battery"
                    "notifications"
                    "volume"
                    "network"
                  ];
                  opacity = widgetsGroupOpacity;
                  padding = widgetsGroupSpacing;
                  radius = widgetsGroupRadius;
                }
                {
                  fill = "surface_variant";
                  id = "g4";
                  members = [
                    "tray"
                  ];
                  opacity = widgetsGroupOpacity;
                  padding = widgetsGroupSpacing;
                  radius = widgetsGroupRadius;
                }
                {
                  fill = "on_secondary";
                  foreground = "on_surface";
                  id = "g5";
                  members = [
                    "weather"
                    "workspaces"
                    "keyboard_layout"
                    "privacy"
                  ];
                  opacity = widgetsGroupOpacity;
                  padding = widgetsGroupSpacing;
                  radius = widgetsGroupRadius;
                }
                {
                  fill = "surface_variant";
                  id = "g6";
                  members = [
                    "brightness"
                    "clock"
                    "taskbar"
                  ];
                  opacity = widgetsGroupOpacity;
                  padding = widgetsGroupSpacing;
                  radius = widgetsGroupRadius;
                }
              ];
            };
            control_center.shortcuts = [
              { type = "wifi"; }
              { type = "bluetooth"; }
              { type = "caffeine"; }
              { type = "notification"; }
              { type = "mic_mute"; }
              { type = "system"; }
            ];
            widget = {
              systemd-inhibit = {
                glyph = "eye-star";
                tooltip = "Calls a btop with systemd-inhibit";
                type = "custom_button";
                actions.left = "noctalia msg caffeine-enable; exec foot -e systemd-inhibit --what=handle-lid-switch:sleep:idle --why=\"Noctalia asked\" btop;";
              };

              launcher.glyph = "snowflake";
              workspaces = {
                hide_when_empty = true;
                display = "none";
                pill_scale = 0.85;
              };
              clock = {
                vertical_format = "{:%H\\n%M}";
              };
              weather = {
                show_condition = false;
                show_temperature = false;
              };
              notifications.show_label = false;
              network = {
                scale = 1.05;
                show_label = false;
              };
              volume.show_label = false;
              battery = {
                display_mode = "graphic";
                capsule_radius = barRadius;
                scale = 0.70;
                show_label = false;
                hide_when_full = false;
              };
              bluetooth = { };
              control-center = {
                glyph = "topology-star-3";
                scale = 0.9;
              };
              cpu = {
                show_label = false;
              };
              keyboard_layout = {
                hide_when_single_layout = true;
              };
              media = {
                art_size = 96.0;
                hide_when_no_media = true;
                max_length = 800;
                title_scroll = "on_hover";
              };
              brightness.show_label = false;
              privacy.hide_inactive = true;
              spacer_2.type = "spacer";
              taskbar = {
                inactive_opacity = 0.74;
                show_active_indicator = false;
              };
            };
          };
        };
      };
    };
    # Hjem block ends
  };
}
