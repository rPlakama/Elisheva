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
    kernelPackages = let
      cachyos =
        if cpu.amd
        then pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-zen4
        else pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v3;
    in
      cachyos.extend (
        final: prev: {
          # ddcci-driver installs modules directly instead of using Kbuild's
          # modules_install, so no .ko.cer signatures are generated. The kernel's
          # modules build concatenates those certificates and fails without them.
          ddcci-driver = prev.ddcci-driver.overrideAttrs (old: {
            postInstall =
              (old.postInstall or "")
              + ''
                find "$out/lib/modules" -name '*.ko' -exec ${pkgs.kmodigest}/bin/kmodigest {} \;
              '';
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
