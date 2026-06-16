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

  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "usb_storage"
      "sd_mod"
      "sdhci_pci"
    ];

    kernelParams = [
      "amd_pstate=active"
      "mem_sleep_default=deep"
      "pcie_aspm.policy=powersupersave"
    ];

    blacklistedKernelModules = [
      "snd_acp_pci"
      "snd_pci_acp3x"
      "snd_pci_acp5x"
      "snd_pci_acp6x"
    ];

    extraModprobeConfig = ''
      options snd-hda-intel dmic_detect=0 rtw89_pci disable_clkreq=y disable_aspm_l1=y disable_aspm_l1ss=y
    '';
    kernelModules = [ "kvm-amd" ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    firmware = [
      pkgs.alsa-firmware
      pkgs.sof-firmware
    ];
  };

}
