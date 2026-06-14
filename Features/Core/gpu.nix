{
  config,
  lib,
  pkgs,
  ...
}:
let
  gpu = config.core.gpu;
in
{
  config = lib.mkMerge [
    (lib.mkIf gpu.amd {
      hardware = {
        graphics = {
          enable = true;
          enable32Bit = true;
          extraPackages = with pkgs; [
            mesa
            libva
          ];
        };
        amdgpu.opencl.enable = true;
      };
      programs.corectrl.enable = true;
      environment.systemPackages = with pkgs; [ radeontop ];
    })

    (lib.mkIf gpu.nvidia {
      services.xserver.videoDrivers = [ "nvidia" ];
      boot = {
        blacklistedKernelModules = [ "nouveau" ];
        kernelParams = [ "modprobe.blacklist=nouveau" ];
      };
      hardware = {
        graphics.enable = true;
        nvidia-container-toolkit.enable = true;
        nvidia = {
          modesetting.enable = true;
          powerManagement.enable = false;
          open = false;
          package = config.boot.kernelPackages.nvidiaPackages.stable;
        };
      };
      environment.systemPackages = with pkgs; [ nvtopPackages.full ];
    })

    (lib.mkIf gpu.intel {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          intel-media-driver
          vpl-gpu-rt
        ];
        extraPackages32 = with pkgs; [ intel-vaapi-driver ];
      };
      environment = {
        sessionVariables.LIBVA_DRIVER_NAME = "iHD";
        systemPackages = with pkgs; [ intel-gpu-tools ];
      };
    })
  ];
}
