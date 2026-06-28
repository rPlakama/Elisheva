{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  user = config.core.user;
  host = config.core.host;

  # display
  primaryMonitor = "eDP-1";

  # styling
  fontFamily = "Montserrat Medium";
  barRadius = 3;

  # widget groups
  widgetsGroupOpacity = 0.0;
  widgetsGroupSpacing = 6.0;
  widgetsGroupRadius = 3.0;
in {
  options.features.noctalia.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.features.niri.NoctaliaEnabled;
    description = "Enable Noctalia window manager environment.";
  };

  config = lib.mkIf config.features.noctalia.enable {
    assertions = [
      {
        assertion = !config.features.niri.DMSEnabled;
        message = "Shall not run two Desktop Shells at same time, choose (Err DMS / Noctalia )";
      }

      {
        assertion = config.features.niri.enable;
        message = "noctalia requires niri";
      }
    ];

    nix.settings = {
      extra-substituters = ["https://noctalia.cachix.org"];
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
      niri.ImportNoctalia = ''include "noctaliaBinds.kdl"'';
      graphicalPkgs.foot.theme = [
        "include=/home/${user}/.config/foot/themes/noctalia"
      ];
      neovim.extraInit = [
        "require('matugen').setup()"
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
              down = ["Ctrl+n"];
              left = ["Ctrl+h"];
              right = ["Ctrl+l"];
              up = ["Ctrl+p"];
            };
            theme = {
              source = "wallpaper";
              community_palette = "Cream Autumn";
              wallpaper_scheme = "m3-rainbow";
              mode = "dark";
              templates = {
                builtin_ids = [
                  "foot"
                  "gtk3"
                  "gtk4"
                  "kcolorscheme"
                  "qt"
                ];
                community_ids = [
                  "neovim"
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
            lockscreen_widgets = {
              enabled = true;
              schema_version = 1;
              widget_order = [
                "lockscreen-login-box@${primaryMonitor}"
                "lockscreen-widget-0000000000000001"
                "lockscreen-widget-0000000000000002"
              ];
              grid = {
                cell_size = 16;
                major_interval = 4;
                visible = true;
              };
              widget = {
                "lockscreen-login-box@${primaryMonitor}" = {
                  box_height = 96.0;
                  box_width = 512.0;
                  cx = 768.0;
                  cy = 480.0;
                  output = primaryMonitor;
                  rotation = 0.0;
                  type = "login_box";
                  settings = {
                    background_color = "surface";
                    background_opacity = 0.92;
                    input_opacity = 1.0;
                    show_login_button = false;
                  };
                };
                "lockscreen-widget-0000000000000001" = {
                  box_height = 64.0;
                  box_width = 512.0;
                  cx = 768.0;
                  cy = 400.0;
                  output = primaryMonitor;
                  rotation = 0.0;
                  type = "clock";
                  settings = {
                    background_radius = widgetsGroupRadius;
                    format = "{:%H:%M}";
                  };
                };
                "lockscreen-widget-0000000000000002" = {
                  box_height = 64.0;
                  box_width = 512.0;
                  cx = 768.0;
                  cy = 560.0;
                  output = primaryMonitor;
                  rotation = 0.0;
                  type = "label";
                  settings = {
                    description = "NixOS ${config.system.nixos.release} ${config.system.nixos.codeName}";
                    background_radius = widgetsGroupRadius;
                    title = "${host}";
                  };
                };
              };
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
              start = ["group:g5"];
              center = ["group:g6"];
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
              {type = "wifi";}
              {type = "bluetooth";}
              {type = "caffeine";}
              {type = "notification";}
              {type = "mic_mute";}
              {type = "system";}
            ];
            widget = {
              launcher.glyph = "snowflake";
              workspaces = {
                hide_when_empty = true;
                display = "none";
                pill_scale = 0.85;
              };
              clock = {
                vertical_format = "{:%H\\n%M}";
              };
              weather.show_condition = false;
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
              bluetooth = {};
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
