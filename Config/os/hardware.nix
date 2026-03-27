{
  config,
  isDesktop,
  isCenturia,
  lib,
  ...
}:
lib.mkMerge [
  (lib.mkIf isCenturia {
    hardware.nvidia-container-toolkit.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];
    boot.blacklistedKernelModules = [
      "nouveau"
      "nova_core"
    ];
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
    };
  })

  (lib.mkIf isDesktop {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = false;
      settings.General.Experimental = true;
    };
  })

  {
    hardware = {
      enableAllFirmware = true;
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
  }
]
