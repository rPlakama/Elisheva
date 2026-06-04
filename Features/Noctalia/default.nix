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
              animation.speed = 1.45;
              panel = {
                launcher_categories = false;
              };
            };
            theme = {
              source = "wallpaper";
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
              default.path = "/home/rplakama/Documents/Nextcloud/wallpapers/cloudorange.jpg";
            };
            location.auto_locate = true;
            lockscreen = {
              blurred_desktop = true;
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
              background_opacity = 0.88;
              radius = 3;
              margin_ends = 105;
              capsule = true;
              capsule_radius = 3;
              capsule_opacity = 0.0;
              start = [
                "launcher"
                "keyboard_layout"
                "workspaces"
              ];
              center = [
                "clock"
                "weather"
              ];
              end = [
                "tray"
                "notifications"
                "network"
                "volume"
                "battery"
                "bluetooth"
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
              network = { };
              volume.show_label = false;
              battery = {
                display_mode = "graphic";
                scale = 0.75;
                show_label = false;
                hide_when_full = true;
              };
              bluetooth = { };
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
          ".config/nvim"
        ];
      };
    };
  };
}
