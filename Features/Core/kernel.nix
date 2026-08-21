{
  config,
  pkgs,
  inputs,
  ...
}: let
  cpu = config.core.cpu;
  ddcciPatch = ./ddcci-string-h.patch;
in {
  nixpkgs.overlays = [inputs.nix-cachyos-kernel.overlays.pinned];

  boot = {
    kernelPackages = let
      cachyos =
        if cpu.amd
        then pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-zen4
        else pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v3;
    in
      cachyos.extend (
        final: prev: {
          # ddcci-driver uses strncpy without including <linux/string.h>,
          # which fails to build on kernels >= 7
          ddcci-driver = prev.ddcci-driver.overrideAttrs (old: {
            patches = (old.patches or []) ++ [ddcciPatch];
          });
        }
      );
    kernelParams =
      if cpu.amd
      then ["amd_pstate=active"]
      else if cpu.intel
      then ["intel_pstate=active"]
      else [];
  };
  assertions = [
    {
      assertion = cpu.amd || cpu.intel;
      message = "core.cpu.amd or core.cpu.intel must be set on each host";
    }
  ];
}
