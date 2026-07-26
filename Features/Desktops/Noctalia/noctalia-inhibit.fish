#!/run/current-system/sw/bin/fish

noctalia msg caffeine-enable
notify-send Caffeine "Enabled — btop session started"
foot -e systemd-inhibit --what=handle-lid-switch:sleep:idle --why="Noctalia asked" btop
noctalia msg caffeine-disable
notify-send Caffeine "Disabled — btop session ended"
