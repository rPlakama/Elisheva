{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.core;
  cpu = config.core.cpu;
in
{
  config = lib.mkIf cfg.enable {
    boot = {
      kernelPackages = (
        if cpu.amd then
          pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-zen4
        # No need to compare to other CPU maker, well, until maybe theres ARM...
        else
          pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v3
      );
      kernelParams = (if cpu.amd then [ "amd_pstate=active" ] else [ "intel_pstate=active" ]);
    };
  };
}
