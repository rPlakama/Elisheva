{ config, lib, ... }:
let
  cfg = config.features.nvidia;
in
{
  options.features.nvidia.enable = lib.mkEnableOption "Nvidia GPU driver";
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
