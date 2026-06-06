{ ... }:

{
  services.tlp = {
    enable = true;
    settings = {
      DISK_DEVICES = "nvme0n1 nvme1n1";

      RUNTIME_PM_DENYLIST = "mei_me nouveau radeon xhci_hcd 0000:04:00.0";

      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      CPU_ENERGY_PERF_POLICY_ON_SAV = "power";

      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "balanced";
      PLATFORM_PROFILE_ON_SAV = "low-power";

      SOUND_POWER_SAVE_ON_AC = 1;
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "Y";

      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
    };
  };
}
