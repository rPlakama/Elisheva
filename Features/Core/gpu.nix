{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkMerge mkIf optionals;
  gpu = config.core.gpu;
  intel = gpu.intel;

  # iHD (intel-media-driver)/oneVPL/Compute-Runtime target Broadwell+ GPUs;
  # the i965 stack (intel-vaapi-driver) is the legacy/fallback for older iGPUs.
  intelDriverPkgs =
    (optionals (!intel.isLegacy) [
      pkgs.intel-media-driver # iHD - modern Intel GPUs (Broadwell+)
      pkgs.vpl-gpu-rt # oneVPL runtime
      pkgs.intel-compute-runtime # Jellyfin tone-mapping and others
    ])
    ++ [
      pkgs.intel-vaapi-driver # i965 - legacy & fallback driver (pre-Broadwell)
      pkgs.libvdpau-va-gl # VDPAU via VA-API
    ];
  intelDriverPkgs32 = (optionals (!intel.isLegacy) [ pkgs.pkgsi686Linux.intel-media-driver ]) ++ [
    pkgs.pkgsi686Linux.intel-vaapi-driver
  ];
in
{
  imports = [ inputs.chaotic.nixosModules.default ];

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
          package = config.boot.kernelPackages.nvidiaPackages.latest;
          nvidiaSettings = true;
        };
      };
    })

    (mkIf (intel.enable || gpu.amd) {
      hardware = {
        amdgpu.opencl.enable = true;
        graphics = {
          enable = true;
          extraPackages = with pkgs; [
            mesa.opencl
          ];
        };
      };
    })

    (mkIf intel.enable {
      hardware.graphics = {
        extraPackages = intelDriverPkgs;
        extraPackages32 = intelDriverPkgs32;
      };

      environment = {
        sessionVariables.LIBVA_DRIVER_NAME = if intel.isLegacy then "i965" else "iHD";
        systemPackages = with pkgs; [
          intel-gpu-tools # intel_gpu_top for monitoring transcode
          libva-utils # vainfo - verify VA-API profiles expose
          clinfo # verify OpenCL
        ];
      };
    })
  ];
}
