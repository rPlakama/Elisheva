{
  config,
  lib,
  ...
}:
let
  cfg = config.features.core;
  cpu = config.core.cpu;
  isLaptop = config.core.isLaptop;
in
{
  config = lib.mkIf cfg.enable {
    boot.kernelParams = lib.mkIf isLaptop (
      if cpu.amd then
        [ "amd_pstate=active" ]
      else if cpu.intel then
        [ "intel_pstate=active" ]
      else
        [ ]
    );
  };
}
