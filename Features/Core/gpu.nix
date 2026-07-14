{
  config,
  lib,
  pkgs,
  ...
}: let
  gpu = config.core.gpu;
in {
  config = lib.mkMerge [
    {services.lact.enable = true;}

    (lib.mkIf gpu.amd {
      hardware = {
        graphics = {
          enable = true;
          enable32Bit = true;
          extraPackages = with pkgs; [
            rocmPackages.clr.icd
            libvdpau-va-gl
          ];
        };
        amdgpu.opencl.enable = true;
      };
      environment.systemPackages = with pkgs; [
        libva-utils
        radeontop
      ];
    })

    (lib.mkIf gpu.nvidia {
      services.xserver.videoDrivers = ["nvidia"];
      boot = {
        blacklistedKernelModules = ["nouveau"];
        kernelParams = [
          "modprobe.blacklist=nouveau"
          "nvidia_drm.fbdev=1"
        ];
      };
      hardware = {
        graphics = {
          enable = true;
          extraPackages = with pkgs; [nvidia-vaapi-driver];
        };
        nvidia-container-toolkit.enable = true;
        nvidia = {
          modesetting.enable = true;
          powerManagement.enable = true;
          open = false;
          package = config.boot.kernelPackages.nvidiaPackages.stable;
          nvidiaSettings = true;
        };
      };
    })

    (lib.mkIf gpu.intel {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          intel-media-driver
          vpl-gpu-rt
        ];
        extraPackages32 = with pkgs; [intel-vaapi-driver];
      };
      environment = {
        sessionVariables.LIBVA_DRIVER_NAME = "iHD";
        systemPackages = with pkgs; [intel-gpu-tools];
      };
    })
  ];
}
