{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkMerge concatStringsSep;
  inherit (lib.lists) filter;
  inherit (lib.strings) removePrefix;

  usesTLP = config.core.isLaptop.usesTLP;

  # --- Hardware context: Lenovo IdeaPad Slim 5 14AKP10 (lenovo/ideapad/14akp10) ---
  # CPU:    AMD Ryzen AI 7 350 -- Krackan Point (Zen 5): 4x 5.0 GHz + 4x Zen 5c 3.5 GHz, 8c/16t
  #         driven by amd-pstate in active mode (EPP), see core.kernel amd_pstate=active
  # GPU:    AMD Radeon 860M (RDNA 3.5, amdgpu) + 14" OLED 60 Hz panel
  # Battery:60 Wh, 65 W USB-C PD (Rapid Charge Boost)
  # Disk:   2x NVMe (primary /dev/nvme1n1, secondary /dev/nvme0n1)
  # Net:    Wi-Fi 7 (802.11be 2x2) + Bluetooth 5.4

  # Derive disk device names from the disko feature to keep this host-agnostic.
  disko = config.features.disko;
  driveNames = filter (d: d != "") (
    map (d: removePrefix "/dev/" d) [ disko.primaryDrive disko.secondaryDrive ]
  );
  diskDevices = if disko.enable && driveNames != [ ] then driveNames else [ "nvme0n1" ];

  # Keep the behaviour of the previous auto-cpufreq setup: performance on AC,
  # powersave on battery, turbo (boost) available in both.
  cpuSettings = {
    CPU_DRIVER_OPMODE_ON_AC = "active";
    CPU_DRIVER_OPMODE_ON_BAT = "active";
    CPU_SCALING_GOVERNOR_ON_AC = "powersave";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
    CPU_ENERGY_PERF_POLICY_ON_SAV = "power";
    CPU_BOOST_ON_AC = 1;
    CPU_BOOST_ON_BAT = 1;
    CPU_BOOST_ON_SAV = 0;
    CPU_SCALING_MIN_FREQ_ON_AC = 400;
    CPU_SCALING_MIN_FREQ_ON_BAT = 400;
    CPU_SCALING_MIN_FREQ_ON_SAV = 400;
    CPU_SCALING_MAX_FREQ_ON_AC = 0;
    CPU_SCALING_MAX_FREQ_ON_BAT = 0;
    # cap the power-saver profile to the Zen 5c ceiling
    CPU_SCALING_MAX_FREQ_ON_SAV = 3500;
  };

  gpuSettings = {
    RADEON_DPM_PERF_LEVEL_ON_AC = "auto";
    RADEON_DPM_PERF_LEVEL_ON_BAT = "auto";
    RADEON_DPM_PERF_LEVEL_ON_SAV = "low";
    # OLED panel adaptive backlight modulation (0 = off, 1..4 = more panel savings)
    AMDGPU_ABM_LEVEL_ON_AC = 0;
    AMDGPU_ABM_LEVEL_ON_BAT = 1;
    AMDGPU_ABM_LEVEL_ON_SAV = 2;
  };

  diskSettings = {
    DISK_DEVICES = concatStringsSep " " diskDevices;
    # No SATA hardware on the 14AKP10, only NVMe -- disable ALPM entirely.
    SATA_LINKPWR_ON_AC = "";
    SATA_LINKPWR_ON_BAT = "";
    AHCI_RUNTIME_PM_ON_AC = "on";
    AHCI_RUNTIME_PM_ON_BAT = "auto";
    AHCI_RUNTIME_PM_TIMEOUT = 15;
  };

  usbSettings = {
    USB_AUTOSUSPEND = 1;
    USB_EXCLUDE_AUDIO = 1;
    USB_EXCLUDE_BTUSB = 1;
    USB_EXCLUDE_PHONE = 1;
    USB_EXCLUDE_PRINTER = 1;
    USB_EXCLUDE_WWAN = 1;
  };

in
{
  services.tlp = mkIf usesTLP {
    enable = true;
    # PPD-compatible DBus interface -> powerprofilesctl works with Niri binds
    pd.enable = true;

    settings = mkMerge [
      # --- Operation ---
      {
        TLP_ENABLE = 1;
        TLP_AUTO_SWITCH = 2; # smart: auto AC/BAT switch, respects manual profile changes
        TLP_WARN_LEVEL = 3;
      }

      # --- Processor (amd-pstate active / EPP) ---
      cpuSettings

      # --- Graphics (Radeon 860M + OLED ABM) ---
      gpuSettings

      # --- Disks and controllers (2x NVMe) ---
      diskSettings

      # --- PCIe autosuspend / ASPM ---
      {
        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "auto";
        RUNTIME_PM_DRIVER_DENYLIST = "mei_me nouveau radeon xhci_hcd";
        PCIE_ASPM_ON_AC = "default";
        PCIE_ASPM_ON_BAT = "powersupersave";
      }

      # --- USB autosuspend ---
      usbSettings

      # --- Networking (Wi-Fi 7 / BT 5.4) ---
      {
        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "on";
        WOL_DISABLE = "Y";
      }

      # --- Audio (snd-hda-intel) ---
      {
        SOUND_POWER_SAVE_ON_AC = 1;
        SOUND_POWER_SAVE_ON_BAT = 1;
        SOUND_POWER_SAVE_CONTROLLER = "Y";
      }

      # --- Platform profile (firmware thermal/fan behaviour, when exposed) ---
      {
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "balanced";
        PLATFORM_PROFILE_ON_SAV = "low-power";
      }

      # --- Kernel ---
      { NMI_WATCHDOG = 0; }

      # --- Battery care: Lenovo non-ThinkPad / ideapad_laptop ---
      # The IdeaPad exposes only a binary "battery conservation mode" (fixed
      # threshold, 60% or 80% depending on model) via lenovo-legacy -- it has
      # no granular thresholds, hence the dummy START value.
      {
        START_CHARGE_THRESH_BAT0 = 0; # dummy value (hardware enforces fixed threshold)
        STOP_CHARGE_THRESH_BAT0 = 1; # 1 = conservation mode, 0 = charge to 100%
        RESTORE_THRESHOLDS_ON_BAT = 1;
      }
    ];
  };
}
