{ config, ... }:
{
  services.xserver.videoDrivers = [ "nvidia" ];
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
