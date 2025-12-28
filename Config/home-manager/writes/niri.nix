{ lib, osConfig, ... }:

let
  isCenturia = osConfig.networking.hostName == "Centuria";

  layoutConfig = if isCenturia then "us,br" else "br";

  mainMod = if isCenturia then "Alt" else "Super";
  nestedMod = if isCenturia then "Super" else "Alt";

  extraBind = lib.optionalString isCenturia ''
    Ctrl+Alt+K { switch-layout "next"; }
  '';
in
{
  home.file.".config/niri/config.kdl" = {
    text = ''
      include "./dms/alttab.kdl"
      include "./dms/colors.kdl"
      include "./dms/wpblur.kdl"

      input {
          keyboard {
              xkb {
                  layout "${layoutConfig}"
                  options "caps:swapescape"
              }
              repeat-delay 600
              repeat-rate 25
              track-layout "global"
              numlock
          }
          touchpad {
              tap
              dwt
              natural-scroll
              accel-speed 0.100000
              accel-profile "adaptive"
              scroll-method "two-finger"
          }
          mouse { accel-speed -0.500000; }
          warp-mouse-to-focus
          workspace-auto-back-and-forth

          // Mod keys dinâmicas baseadas no host
          mod-key "${mainMod}"
          mod-key-nested "${nestedMod}"
      }

      output "HDMI-A-1" {
          scale 1.000000
          transform "normal"
          position x=0 y=0
      }
      output "eDP-1" {
          scale 1.400000
          transform "normal"
          mode "1920x1080@74.986000"
      }

      screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"
      prefer-no-csd

      overview {
          workspace-shadow {
              softness 300
              spread 300
          }
      }

      layout {
          gaps 3
          struts {
              left 3
              right 3
              top 3
              bottom 3
          }
          focus-ring { off; }
          border {
              width 2
          }
          shadow {
              on
              offset x=0.000000 y=5.000000
              softness 10
              spread 6
              draw-behind-window true
          }
          default-column-width { proportion 0.500000; }
          preset-column-widths {
              proportion 0.250000
              proportion 0.500000
              proportion 0.750000
          }
          center-focused-column "never"
      }

      cursor {
          xcursor-theme "volantes_light_cursors"
          xcursor-size 24
      }

      hotkey-overlay { skip-at-startup; }

      binds {
          ${extraBind}

          Ctrl+Alt+A { spawn "dms" "ipc" "call" "dash" "toggle" "overview"; }
          Ctrl+Alt+C { spawn "dms" "ipc" "call" "control-center" "toggle"; }
          Ctrl+Alt+D { spawn "dms" "ipc" "call" "dash" "toggle" "media"; }
          Ctrl+Alt+L { spawn "dms" "ipc" "call" "wallpaper" "next"; }
          Ctrl+Alt+S { spawn "dms" "ipc" "call" "powermenu" "toggle"; }
          Ctrl+Alt+W { spawn "dms" "ipc" "call" "dankdash" "wallpaper"; }

          Mod+0 { focus-workspace 10; }
          Mod+1 { focus-workspace 1; }
          Mod+2 { focus-workspace 2; }
          Mod+3 { focus-workspace 3; }
          Mod+4 { focus-workspace 4; }
          Mod+5 { focus-workspace 5; }
          Mod+6 { focus-workspace 6; }
          Mod+7 { focus-workspace 7; }
          Mod+8 { focus-workspace 8; }
          Mod+9 { focus-workspace 9; }

          Mod+B { spawn-sh "foot -e ~/Music/music.sh"; }
          Mod+BracketLeft { consume-or-expel-window-left; }
          Mod+BracketRight { consume-or-expel-window-right; }
          Mod+C { center-column; }
          Mod+F { maximize-column; }
          Mod+H { focus-column-left; }
          Mod+J { focus-window-or-workspace-down; }
          Mod+K { focus-window-or-workspace-up; }
          Mod+L { focus-column-right; }
          Mod+M { spawn "dms" "ipc" "call" "processlist" "toggle"; }
          Mod+N { spawn "dms" "ipc" "call" "notifications" "toggle"; }
          Mod+P { spawn-sh "wl-mirror $(niri msg --json focused-output | jq -r .name)"; }
          Mod+R { switch-preset-column-width-back; }

          Mod+Return { spawn "foot"; }
          Mod+Shift+C { center-visible-columns; }
          Mod+Shift+F { fullscreen-window; }
          Mod+Shift+H { move-column-left; }
          Mod+Shift+J { move-column-to-workspace-down; }
          Mod+Shift+K { move-column-to-workspace-up; }
          Mod+Shift+L { move-column-right; }
          Mod+Shift+R { switch-preset-column-width; }

          Mod+Space { spawn "dms" "ipc" "call" "spotlight" "toggle"; }
          Mod+Tab { toggle-overview; }
          Mod+V { spawn "dms" "ipc" "call" "clipboard" "toggle"; }
          Mod+W { close-window; }
          Mod+Y { spawn-sh "foot -e yazi"; }
          Print { screenshot; }

          XF86AudioLowerVolume { spawn-sh "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-; dms ipc call audio increment 0"; }
          XF86AudioMute { spawn "dms" "ipc" "call" "audio" "mute"; }
          XF86AudioPlay { spawn "dms" "ipc" "call" "mpris" "playPause"; }
          XF86AudioRaiseVolume { spawn-sh "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+; dms ipc call audio increment 0"; }
          XF86MonBrightnessDown { spawn "dms" "ipc" "call" "brightness" "decrement" "5" ""; }
          XF86MonBrightnessUp { spawn "dms" "ipc" "call" "brightness" "increment" "5" ""; }
      }

      window-rule {
          match is-focused=false
          opacity 1.000000
      }
      window-rule {
          geometry-corner-radius 2.000000 2.000000 2.000000 2.000000
          clip-to-geometry true
      }
      window-rule {
          match app-id="firefox$" title="^Picture-in-Picture$"
          open-floating true
      }
      layer-rule {
          match namespace="^quickshell$"
          place-within-backdrop true
      }
      animations {
          slowdown 1.000000
          horizontal-view-movement {
              duration-ms 300
              curve "cubic-bezier" 0 1 0 1
          }
          overview-open-close {
              duration-ms 300
              curve "cubic-bezier" 0 1 0 1
          }
          window-close {
              duration-ms 300
              curve "cubic-bezier" 0 1 0 1
          }
          window-movement {
              duration-ms 300
              curve "cubic-bezier" 0 1 0 1
          }
          window-open {
              duration-ms 300
              curve "cubic-bezier" 0 1 0 1
          }
          window-resize {
              duration-ms 300
              curve "cubic-bezier" 0 1 0 1
          }
          workspace-switch {
              duration-ms 300
              curve "cubic-bezier" 0 1 0 1
          }
      }

      recent-windows {
          debounce-ms 750
          open-delay-ms 0
          previews {
              max-height 600
              max-scale 0.3
          }
          binds {
              Ctrl+Alt+E    { next-window; }
              Ctrl+Alt+Q    { previous-window; }
          }
      }
    '';
  };
}
