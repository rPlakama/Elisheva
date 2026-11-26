{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib)
    mkMerge
    mkIf
    mkOption
    types
    optionals
    ;
  gpu = config.core.gpu;
  intel = gpu.intel;

  # Intel generations and what each one needs:
  #   isLegacy  (pre-Gen 8, before Broadwell) : i965 only
  #   default   (Gen 8-11, Broadwell..Ice Lake, e.g. Kaby Lake i5-7600)
  #                                            : iHD + legacy compute runtime, VAAPI only
  #   gen12Plus (Tiger Lake / Alder Lake and newer)
  #                                            : iHD + oneVPL (QSV) + current compute runtime
  # intel-media-sdk (QSV for Gen 8-11) is EOL with CVEs, so it is intentionally not used.
  intelModern = !intel.isLegacy;

  intelDriverPkgs =
    with pkgs;
    (optionals intelModern [ intel-media-driver ]) # iHD, VAAPI (Broadwell+)
    ++ (optionals (intelModern && !intel.gen12Plus) [
      intel-compute-runtime-legacy1 # OpenCL for Gen 8-11, used by tone mapping
    ])
    ++ (optionals (intelModern && intel.gen12Plus) [
      vpl-gpu-rt # oneVPL runtime (QSV on Gen 12+)
      intel-compute-runtime # OpenCL for Gen 12+
    ])
    ++ [
      intel-vaapi-driver # i965, legacy and fallback driver
      libvdpau-va-gl # VDPAU via VA-API
    ];

  intelDriverPkgs32 = (optionals intelModern [ pkgs.pkgsi686Linux.intel-media-driver ]) ++ [
    pkgs.pkgsi686Linux.intel-vaapi-driver
  ];

  libvaDriver = if intel.isLegacy then "i965" else "iHD";
in
{
  imports = [
    inputs.chaotic.nixosModules.default
  ];

  options.core.gpu.intel.gen12Plus = mkOption {
    type = types.bool;
    default = false;
    description = "Intel iGPU is Gen 12 (Tiger Lake / Alder Lake) or newer. Leave false for Gen 8-11 such as Kaby Lake.";
  };

  config = mkMerge [
    # ---------------------------------------------------------------- NVIDIA
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

    # ---------------------------------------------------- Shared (Intel / AMD)
    (mkIf (intel.enable || gpu.amd) {
      hardware.graphics = {
        enable = true;
        enable32Bit = !config.core.headless;
      };
    })

    # ------------------------------------------------------------------- AMD
    (mkIf gpu.amd {
      hardware.amdgpu.opencl.enable = true;
    })

    # ----------------------------------------------------------------- Intel
    (mkIf intel.enable {
      hardware.graphics = {
        extraPackages = intelDriverPkgs;
        extraPackages32 = mkIf (!config.core.headless) intelDriverPkgs32;
      };

      environment = {
        sessionVariables.LIBVA_DRIVER_NAME = libvaDriver;
        systemPackages = with pkgs; [
          intel-gpu-tools # intel_gpu_top, monitor transcodes
          libva-utils # vainfo, verify VA-API profiles
          clinfo # verify OpenCL
        ];
      };

      # sessionVariables only reach login shells; the Jellyfin unit needs its own copy.
      systemd.services.jellyfin.environment = mkIf config.services.jellyfin.enable {
        LIBVA_DRIVER_NAME = libvaDriver;
      };
    })
  ];
}
