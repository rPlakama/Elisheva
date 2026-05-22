{ config, lib, ... }:
let
  cfg = config.core.features.nvidia;
in
{
  options.core.features.nvidia.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Nvidia driver configuration";
    default = false;
  };
  config = lib.mkIf cfg.enable {
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
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };
    };
  };
}
