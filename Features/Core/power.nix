{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  isLaptop = config.core.isLaptop.enable;
in {
  powerManagement.resumeCommands = mkIf isLaptop ''
    for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
      if [ -w "$cpu/cpufreq/energy_performance_preference" ]; then
        if [ "$(cat /sys/class/power_supply/ACAD/online 2>/dev/null)" = "1" ]; then
          echo balance_performance > "$cpu/cpufreq/energy_performance_preference"
        else
          echo balance_power > "$cpu/cpufreq/energy_performance_preference"
        fi
      fi
    done
    if [ -w /sys/devices/system/cpu/cpufreq/boost ]; then
      echo 1 > /sys/devices/system/cpu/cpufreq/boost
    fi
  '';
}
