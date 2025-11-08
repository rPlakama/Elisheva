{config, ...}: {
  programs.niri.settings.binds = with config.lib.niri.actions; {
    "Mod+Space".action = spawn ["dms" "ipc" "call" "spotlight" "toggle"];
    "Mod+V".action = spawn ["dms" "ipc" "call" "clipboard" "toggle"];
    "Mod+M".action = spawn ["dms" "ipc" "call" "processlist" "toggle"];
    "Mod+N".action = spawn ["dms" "ipc" "call" "notifications" "toggle"];
    "Ctrl+Alt+D".action = spawn ["dms" "ipc" "call" "dash" "toggle" "media"];
    "Ctrl+Alt+A".action = spawn ["dms" "ipc" "call" "dash" "toggle" "overview"];
    "Ctrl+Alt+W".action = spawn ["dms" "ipc" "call" "dankdash" "wallpaper"];
    "Ctrl+Alt+L".action = spawn ["dms" "ipc" "call" "wallpaper" "next"];
    "Ctrl+Alt+C".action = spawn ["dms" "ipc" "call" "control-center" "toggle"];
    "Ctrl+Alt+S".action = spawn ["dms" "ipc" "call" "powermenu" "toggle"];
    "XF86AudioPlay".action = spawn ["dms" "ipc" "call" "mpris" "playPause"];
    "XF86AudioMute".action = spawn ["dms" "ipc" "call" "audio" "mute"];
    "XF86MonBrightnessUp".action = spawn ["dms" "ipc" "call" "brightness" "increment" "5" ""];
    "XF86MonBrightnessDown".action = spawn ["dms" "ipc" "call" "brightness" "decrement" "5" ""];
    "XF86AudioRaiseVolume".action = spawn-sh ["wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+; dms ipc call audio increment 0"];
    "XF86AudioLowerVolume".action = spawn-sh ["wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-; dms ipc call audio increment 0"];

    "Mod+1".action = focus-workspace 1;
    "Mod+2".action = focus-workspace 2;
    "Mod+3".action = focus-workspace 3;
    "Mod+4".action = focus-workspace 4;
    "Mod+5".action = focus-workspace 5;
    "Mod+6".action = focus-workspace 6;
    "Mod+7".action = focus-workspace 7;
    "Mod+8".action = focus-workspace 8;
    "Mod+9".action = focus-workspace 9;
    "Mod+0".action = focus-workspace 10;

    "Mod+Tab".action = toggle-overview;
    "Mod+W".action = close-window;
    "Mod+R".action = switch-preset-column-width-back;
    "Mod+Shift+R".action = switch-preset-column-width;
    "Mod+C".action = center-column;
    "Mod+Shift+C".action = center-visible-columns;
    "Mod+BracketLeft".action = consume-or-expel-window-left;
    "Mod+BracketRight".action = consume-or-expel-window-right;
    "Mod+F".action = maximize-column;
    "Mod+Shift+F".action = fullscreen-window;

    "Print".action.screenshot = [];

    "Mod+L".action = focus-column-right;
    "Mod+H".action = focus-column-left;
    "Mod+K".action = focus-window-or-workspace-up;
    "Mod+J".action = focus-window-or-workspace-down;
    "Mod+Shift+L".action = move-column-right;
    "Mod+Shift+H".action = move-column-left;

    "Mod+Shift+K".action = move-column-to-workspace-up;
    "Mod+Shift+J".action = move-column-to-workspace-down;

    "Mod+Return".action = spawn "foot";
    "Mod+Y".action = spawn-sh "foot -e yazi";
  };
}
