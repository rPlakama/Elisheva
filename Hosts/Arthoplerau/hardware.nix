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
      "snd_pci_acp3x"
      "snd_pci_acp5x"
      "snd_pci_acp6x"
    ];

    kernelParams = [
      "iommu=pt"
      "acpi_enforce_resources=lax"
    ];

    extraModprobeConfig = "options rtw89_core disable_ps_mode=1";
    kernelModules = [
      "kvm-amd"
    ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    firmware = with pkgs; [
      sof-firmware
    ];
  };
}
