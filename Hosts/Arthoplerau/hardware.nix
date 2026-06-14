{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usb_storage"
    "sd_mod"
    "sdhci_pci"
  ];

  boot.kernelModules = [ "kvm-amd" ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  services.tlp = {
    enable = false;
    settings = {
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "balanced";

      STOP_CHARGE_THRESH_BAT0 = 80;

      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "Y";

      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";

      SCHED_POWERSAVE_ON_AC = 0;
      SCHED_POWERSAVE_ON_BAT = 1;
      NMI_WATCHDOG = 0;
      WOL_DISABLE = "Y";
      USB_AUTOSUSPEND = 1;
      PCIE_ASPM_ON_AC = "performance";
      PCIE_ASPM_ON_BAT = "powersave";
    };
  };
  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    firmware = [ pkgs.sof-firmware ];
  };

}
