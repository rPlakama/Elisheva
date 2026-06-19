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

    blacklistedKernelModules = [
      "snd_acp_pci"
      "snd_pci_acp3x"
      "snd_pci_acp5x"
      "snd_pci_acp6x"
    ];

    extraModprobeConfig = ''
      options snd-hda-intel dmic_detect=0
    '';

    kernelParams = [
      "mem_sleep_default=deep"
      "libata.noacpi=1"
    ];

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
