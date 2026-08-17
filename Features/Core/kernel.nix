{
  config,
  pkgs,
  ...
}:
let
  cpu = config.core.cpu;
in
{
  boot = {
    kernelPackages = (
      if cpu.amd then pkgs.linuxPackages_cachyos-lto-znver4 else pkgs.linuxPackages_cachyos
    );
    kernelParams =
      if cpu.amd then
        [ "amd_pstate=active" ]
      else if cpu.intel then
        [ "intel_pstate=active" ]
      else
        [ ];
  };
  assertions = [
    {
      assertion = cpu.amd || cpu.intel;
      message = "core.cpu.amd or core.cpu.intel must be set on each host";
    }
  ];
}
