{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.features.noctalia;
  user = config.core.user;
  widgetsGroupOpacity = 0.0;
  widgetsGroupSpacing = 6.0;
  widgetsGroupRadius = 3.0;

in
{
  options.features.noctalia.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.features.niri.NoctaliaEnabled;
    description = "Enable Noctalia window manager environment.";
  };
  config = lib.mkIf cfg.enable {
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
      extra-substituters = [ "https://noctalia.cachix.org" ];
      extra-trusted-public-keys = [
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
    };
    boot.consoleLogLevel = 0;
    environment.systemPackages = [
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
      pkgs.ddcutil
    ];
    services = {
      ddccontrol.enable = true;
      displayManager.ly = {
        enable = true;
        settings = {
          default_input = "password";
        };
      };
    };
    systemd.user.services.niri-flake-polkit.enable = false;
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
              font_family = "Montserrat Medium";
              niri_overview_type_to_launch_enabled = true;
              password_style = "random";
              polkit_agent = true;
              animation.speed = 0.8;
              panel = {
                launcher_categories = true;
              };
            };
            keybinds = {
              down = [ "Ctrl+n" ];
              left = [ "Ctrl+h" ];
              right = [ "Ctrl+l" ];
              up = [ "Ctrl+p" ];
            };
            theme = {
              source = "community";
              community_palette = "Flexoki";
              templates = {
                community_ids = [ "neovim" ];
                builtin_ids = [
                  "foot"
                  "gtk3"
                  "gtk4"
                  "qt"
                ];
              };
              wallpaper_scheme = "m3-tonal-spot";
            };
            wallpaper = {
              enabled = true;
              directory = "/home/${user}/Documents/Nextcloud/wallpapers/";
              transition_on_startup = true;
              default.path = "/home/${user}/Documents/Nextcloud/wallpapers/bsd.png";
              last.path = "/home/${user}/Documents/Nextcloud/wallpapers/bsd.png";
              monitors."eDP-1".path = "/home/${user}/Documents/Nextcloud/wallpapers/bsd.png";
            };
            location.auto_locate = true;
            lockscreen = {
              blurred_desktop = true;
              blur_intensity = 0.65;
              tint_intensity = 0.0;
            };
            lockscreen_widgets = {
              enabled = false;
              schema_version = 1;
              widget_order = [ "lockscreen-login-box@eDP-1" ];
              grid = {
                cell_size = 16;
                major_interval = 4;
                visible = true;
              };
              widget."lockscreen-login-box@eDP-1" = {
                cx = 768.0;
                cy = 837.0;
                output = "eDP-1";
                rotation = 0.0;
                scale = 1.0;
                type = "login_box";
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
              background_opacity = 1.0;
              radius = 3;
              margin_ends = 105;
              capsule = false;
              capsule_radius = 3;
              capsule_opacity = 0.0;
              start = [ "group:g5" ];
              center = [ "group:g6" ];
              end = [
                "group:g4"
                "group:g3"
                "group:g2"
                "group:g1"
              ];
              capsule_group = [
                {
                  fill = "surface_variant";
                  id = "g1";
                  members = [
                    "volume"
                    "network"
                  ];
                  opacity = widgetsGroupOpacity;
                  padding = widgetsGroupSpacing;
                  radius = widgetsGroupRadius;

                }
                {
                  fill = "surface_variant";
                  id = "g2";
                  members = [
                    "bluetooth"
                    "notifications"
                  ];
                  opacity = widgetsGroupOpacity;
                  padding = widgetsGroupSpacing;
                  radius = widgetsGroupRadius;
                }
                {
                  fill = "surface_variant";
                  id = "g3";
                  members = [
                    "cpu"
                    "battery"
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
                    "control-center"
                  ];
                  opacity = widgetsGroupOpacity;
                  padding = widgetsGroupSpacing;
                  radius = widgetsGroupRadius;
                }
                {
                  fill = "surface_variant";
                  id = "g5";
                  members = [
                    "workspaces"
                    "keyboard_layout"
                    "launcher"
                  ];
                  opacity = widgetsGroupOpacity;
                  padding = widgetsGroupSpacing;
                  radius = widgetsGroupRadius;
                }
                {
                  fill = "surface_variant";
                  id = "g6";
                  members = [
                    "weather"
                    "clock"
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
              { type = "sysmon"; }
            ];
            widget = {
              launcher.glyph = "snowflake";
              workspaces.display = "none";
              clock = { };
              weather.show_condition = false;
              notifications.show_label = false;
              network = {
                scale = 1.05;
                show_label = false;
              };
              volume.show_label = false;
              battery = {
                display_mode = "graphic";
                capsule_radius = 3;
                scale = 0.69999999999999996;
                show_label = false;
                hide_when_full = true;
                hide_when_plugged = true;
              };
              bluetooth = { };
              control-center = {
                glyph = "topology-star-3";
              };
              cpu = {
                show_label = false;
              };
              keyboard_layout = {
                hide_when_single_layout = true;
              };
            };
          };
        };
      };
    };
    features = {
      niri.ImportNoctalia = ''include "noctaliaBinds.kdl"'';
      graphicalPkgs.foot.theme = [
        "include=/home/${user}/.config/foot/themes/noctalia"
      ];
      neovim.extraInit = [
        "require('matugen').setup()"
      ];
      preservation = {
        persistDirs.home = [
          ".config/niri"
          ".config/gtk-4.0"
          ".config/gtk-3.0"
          ".config/dconf"
          ".config/nvim/lua/matugen.lua"
        ];
      };
    };
  };
}
