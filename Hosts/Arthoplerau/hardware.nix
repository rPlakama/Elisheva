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
    initrd = {
      kernelModules = [
        "amdgpu"
      ];
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usb_storage"
        "sd_mod"
        "sdhci_pci"
      ];
    };

    blacklistedKernelModules = [
      "snd_acp_pci"
    ];

    extraModprobeConfig = ''
      		 options rtw89_pci disable_aspm_l1ss=Y disable_aspm_l1=Y
           options snd-hda-intel dmic_detect=0 '';
    kernelModules = [
      "kvm-amd"
    ];
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
