{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkMerge mkIf;
  gpu = config.core.gpu;
in
{
  config = mkMerge [

    (mkIf gpu.nvidia {
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware = {
        graphics = {
          enable = true;
          extraPackages = with pkgs; [ nvidia-vaapi-driver ];
        };
        nvidia-container-toolkit.enable = true;
        nvidia = {
          modesetting.enable = true;
          powerManagement.enable = true;
          open = true;
          package = with pkgs; nvidia_cachyos-lto;
          nvidiaSettings = true;
        };
      };
    })

    (mkIf (gpu.intel || gpu.amd) {
      chaotic.mesa-git.enable = true;
      hardware.graphics = {
        enable = true;
      };
    })

    (mkIf gpu.intel {
      hardware.graphics = {
        extraPackages = with pkgs; [
          intel-media-driver
          vpl-gpu-rt
          intel-vaapi-driver
        ];
      };
      environment = {
        sessionVariables.LIBVA_DRIVER_NAME = "iHD";
        systemPackages = with pkgs; [ intel-gpu-tools ];
      };
    })
  ];
}
