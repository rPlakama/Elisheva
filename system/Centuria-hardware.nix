{ config, ... }:
{
  harware = {
    nvidia-container.toolkit.enable = true; # <-- Docker
    nvidia = {
      modsetting.enable = true;
      powerManagment.enable = false;
      open = false;
      package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
    };
  };
}
