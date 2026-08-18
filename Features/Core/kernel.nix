{
  config,
  pkgs,
  inputs,
  ...
}: let
  cpu = config.core.cpu;
in {
  nixpkgs.overlays = [inputs.nix-cachyos-kernel.overlays.pinned];

  boot = {
    kernelPackages = (
      if cpu.amd
      then pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-zen4
      else pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v3
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
