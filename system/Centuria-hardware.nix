{ config, ... }:
{
  services.xserver.videoDrivers = [ "nvidia" ];
  boot = {
    blacklistedKernelModules = [ "nouveau" ];
    kernelParams = [ "modprobe.blacklist=nouveau" ];
  };

  hardware = {
    nvidia-container-toolkit.enable = true;
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      open = false;
      package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
    };
  };
}
