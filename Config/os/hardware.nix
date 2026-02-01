{
  config,
  lib,
  ...
}:
lib.mkMerge [
  (lib.mkIf (config.networking.hostName == "Centuria") {
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

  (lib.mkIf (config.networking.hostName == "Elisheva") {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = false;
      settings.General.Experimental = true;
    };
  })

  {
    hardware.enableAllFirmware = true;
    hardware.graphics.enable = true;
  }
]
