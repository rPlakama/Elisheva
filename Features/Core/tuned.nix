{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  usesTunedPPD = config.core.isLaptop.usesTunedPPD;
  # --- Hardware context: Lenovo IdeaPad Slim 5 14AKP10 (MTM 83NJ) ---
  # CPU:    AMD Ryzen AI 7 350 -- Krackan Point (Zen 5): 4x 5.0 GHz + 4x Zen 5c 3.5 GHz, 8c/16t
  #         driven by amd-pstate in active mode (EPP), see core.kernel amd_pstate=active
  # GPU:    AMD Radeon 860M (RDNA 3.5, amdgpu) + 14" OLED 60 Hz panel
  # Battery:60 Wh, 65 W USB-C PD (Rapid Charge Boost)
  # Disk:   2x NVMe (primary /dev/nvme1n1, secondary /dev/nvme0n1)
  # Net:    Wi-Fi 7 (802.11be 2x2) + Bluetooth 5.4
  #
  # The ideapad_laptop EC exposes /sys/firmware/acpi/platform_profile on this
  # model, so the [acpi] platform_profile keys below drive the real firmware
  # thermal/fan behaviour through tuned-ppd's sysfs monitor.
in {
  services.tuned = mkIf usesTunedPPD {
    enable = true;
    ppdSupport = true;

    settings = {
      daemon = true;
      # Deterministic profiles; dynamic tuning would fight the EPP values below.
      dynamic_tuning = false;
    };

    ppdSettings = {
      main = {
        default = "balanced";
        battery_detection = true;
      };
      profiles = {
        "power-saver" = "ideapad-powersave";
        balanced = "ideapad-balanced";
        performance = "ideapad-performance";
      };
      battery.balanced = "ideapad-balanced-battery";
    };

    profiles = {
      "ideapad-performance" = {
        main.summary = "Max performance (83NJ): amd-pstate EPP performance, boost on, EC profile performance";
        cpu = {
          governor = "performance";
          energy_performance_preference = "performance";
          boost = 1;
        };
        acpi.platform_profile = "performance";
        audio.timeout = 1;
      };

      "ideapad-balanced" = {
        main.summary = "Balanced (83NJ): amd-pstate EPP balance_performance, boost on, EC profile balanced";
        cpu = {
          governor = "powersave";
          energy_performance_preference = "balance_performance";
          boost = 1;
        };
        acpi.platform_profile = "balanced";
        audio.timeout = 1;
      };

      "ideapad-balanced-battery" = {
        main.summary = "Balanced on battery (83NJ): shift EPP to balance_power";
        main.include = "ideapad-balanced";
        cpu.energy_performance_preference = "balance_power";
      };

      "ideapad-powersave" = {
        main.summary = "Max battery life (83NJ): EPP power, boost off, quiet EC profile";
        cpu = {
          governor = "powersave";
          energy_performance_preference = "power";
          boost = 0;
        };
        acpi.platform_profile = "low-power|quiet";
        audio.timeout = 1;
        sysctl = {
          "vm.laptop_mode" = 5;
          "vm.dirty_writeback_centisecs" = 1500;
          "kernel.nmi_watchdog" = 0;
        };
      };
    };
  };
}
