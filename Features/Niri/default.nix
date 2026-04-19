{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.optionals.features.niri;
  user = config.core.user;
  currentHost = config.networking.hostName;

  standardBezier = {
    curve = "cubic-bezier";
    duration-ms = 452;
    curve-args = [
      0.20
      1.0
      0.20
      1.0
    ];
  };
in
{
  imports = [
    inputs.niri-nix.nixosModules.default
    inputs.dms.nixosModules.dank-material-shell
  ];

  options.optionals.features.niri.enable = lib.mkOption {
    description = "Niri Configuration";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf cfg.enable {

    systemd.user.services.niri-flake-polkit.enable = false;

    nix.settings = {
      substituters = [ "https://niri-nix.cachix.org" ];
      trusted-public-keys = [
        "niri-nix.cachix.org-1:SvFtqpDcf7Sm1SMJdby1/+Y+6f3Yt3/3PMcSTKPJNJ0="
      ];
    };
    nixpkgs.overlays = [ inputs.niri-nix.overlays.niri-nix ];

    programs = {
      niri = {
        enable = true;
        package = pkgs.niri-unstable;
      };
      dank-material-shell = {
        enable = true;
        enableCalendarEvents = false;
        systemd = {
          enable = true;
          restartIfChanged = true;
        };
      };
    };

    environment.systemPackages = with pkgs; [
      papers
      nautilus
      loupe
      xwayland-satellite
      papirus-folders
      papirus-icon-theme
      volantes-cursors
    ];

    services = {
      power-profiles-daemon.enable = lib.mkForce false;
      displayManager.dms-greeter = {
        enable = true;
        compositor.name = "niri";
        configHome = "/home/${user}";
      };
    };

    home-manager.users.${user} = {
      imports = [
        inputs.niri-nix.homeModules.default
        inputs.dms.homeModules.dank-material-shell
      ];

      programs.dank-material-shell.enable = true;
      wayland.windowManager.niri = {
        enable = true;
        settings = {
          input = {
            keyboard = {
              xkb = {
                layout = if currentHost == "Centuria" then "us,br" else "br";
                options = "caps:swapescape";
              };
              repeat-delay = 600;
              repeat-rate = 25;
              track-layout = "global";
              numlock = true;
            };

            touchpad = {
              tap = true;
              dwt = true;
              natural-scroll = true;
              accel-speed = 0.1;
              accel-profile = "adaptive";
              scroll-method = "two-finger";
            };

            mouse = {
              accel-speed = -0.5;
            };

            warp-mouse-to-focus.enable = true;
            workspace-auto-back-and-forth = true;

            mod-key = "Super";
            mod-key-nested = "Alt";
          };

          screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
          prefer-no-csd = true;

          overview = {
            workspace-shadow = {
              softness = 15;
              spread = 10;
            };
          };

          layout = {
            shadow = {
              spread = 1;
              softness = 10;
            };
            border.off._args = [ ];
            focus-ring._args = [ ];
            default-column-width.proportion = 0.333333;
            preset-column-widths._children = [
              { proportion = 0.333333; }
              { proportion = 0.666667; }
            ];
            center-focused-column = "never";
          };

          hotkey-overlay.skip-at-startup = true;

          binds =
            let
              dms = args: {
                action.spawn = [
                  "dms"
                  "ipc"
                  "call"
                ]
                ++ args;
              };
              sh = cmd: { action.spawn-sh = cmd; };
            in
            {
              "Ctrl+Alt+A" = dms [
                "dash"
                "toggle"
                "overview"
              ];
              "Ctrl+Alt+C" = dms [
                "control-center"
                "toggle"
              ];
              "Ctrl+Alt+D" = dms [
                "dash"
                "toggle"
                "media"
              ];
              "Ctrl+Alt+L" = dms [
                "wallpaper"
                "next"
              ];
              "Ctrl+Alt+S" = dms [
                "powermenu"
                "toggle"
              ];
              "Ctrl+Alt+W" = dms [
                "dankdash"
                "wallpaper"
              ];

              "Mod+0".action.focus-workspace = 10;
              "Mod+1".action.focus-workspace = 1;
              "Mod+2".action.focus-workspace = 2;
              "Mod+3".action.focus-workspace = 3;
              "Mod+4".action.focus-workspace = 4;
              "Mod+5".action.focus-workspace = 5;
              "Mod+6".action.focus-workspace = 6;
              "Mod+7".action.focus-workspace = 7;
              "Mod+8".action.focus-workspace = 8;
              "Mod+9".action.focus-workspace = 9;

              "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
              "Mod+BracketRight".action.consume-or-expel-window-right = [ ];
              "Mod+C".action.center-column = [ ];
              "Mod+F".action.maximize-column = [ ];
              "Mod+H".action.focus-column-left = [ ];
              "Mod+J".action.focus-window-or-workspace-down = [ ];
              "Mod+K".action.focus-window-or-workspace-up = [ ];
              "Mod+L".action.focus-column-right = [ ];
              "Mod+M" = dms [
                "processlist"
                "toggle"
              ];
              "Mod+N" = dms [
                "notifications"
                "toggle"
              ];
              "Mod+P" = sh "wl-mirror $(niri msg --json focused-output | jq -r .name)";

              "Mod+R".action.switch-preset-column-width-back = [ ];
              "Mod+Shift+R".action.switch-preset-column-width = [ ];

              "Mod+Q".action.set-window-height = "+10%";
              "Mod+Shift+Q".action.set-window-height = "-10%";

              "Mod+Return".action.spawn = "foot";
              "Mod+Shift+C".action.center-visible-columns = [ ];
              "Mod+Shift+F".action.fullscreen-window = [ ];
              "Mod+Shift+H".action.move-column-left = [ ];
              "Mod+Shift+J".action.move-column-to-workspace-down = [ ];
              "Mod+Shift+K".action.move-column-to-workspace-up = [ ];
              "Mod+Shift+L".action.move-column-right = [ ];

              "Mod+Space" = dms [
                "spotlight"
                "toggle"
              ];
              "Mod+Tab".action.toggle-overview = [ ];
              "Mod+V" = dms [
                "clipboard"
                "toggle"
              ];
              "Mod+W".action.close-window = [ ];
              "Mod+Y" = sh "foot -e yazi";
              "Print".action.screenshot = [ ];

              "XF86AudioLowerVolume" =
                sh "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-; dms ipc call audio increment 0";
              "XF86AudioMute" = dms [
                "audio"
                "mute"
              ];
              "XF86AudioPlay" = dms [
                "mpris"
                "playPause"
              ];
              "XF86AudioRaiseVolume" =
                sh "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+; dms ipc call audio increment 0";
              "XF86MonBrightnessDown" = dms [
                "brightness"
                "decrement"
                "5"
                ""
              ];
              "XF86MonBrightnessUp" = dms [
                "brightness"
                "increment"
                "5"
                ""
              ];
            }
            // lib.optionalAttrs (currentHost == "Centuria") {
              "Ctrl+Alt+K".action.switch-layout = "next";
            };

          layer-rule = [
            {
              match = [ { } ];
            }
          ];
          window-rule = [
            {
              match = [
                { _props.is-active = false; }
              ];
              opacity = 0.35;
            }
          ];

          animations = {
            slowdown = 0.8;
            workspace-switch.kind.easing = standardBezier;
            horizontal-view-movement.kind.easing = standardBezier;
            overview-open-close.kind.easing = standardBezier;
            config-notification-open-close.kind.easing = standardBezier;
            exit-confirmation-open-close.kind.easing = standardBezier;
            screenshot-ui-open.kind.easing = standardBezier;
            window-open.kind.easing = standardBezier;
            window-resize.kind.easing = standardBezier;
            window-close.kind.easing = standardBezier;
            window-movement.kind.easing = standardBezier;
          };
        };

        extraConfig = ''
          include "dms/colors.kdl"
          include "dms/layout.kdl"
          include "dms/alttab.kdl"
          include "dms/binds.kdl"
        '';
      };
    };
  };
}
