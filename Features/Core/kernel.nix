{
  config,
  lib,
  ...
}: let
  cfg = config.features.core;
  cpu = config.core.cpu;
in {
  config = lib.mkIf cfg.enable {
    boot.kernelParams =
      (
        if cpu.amd
        then ["amd_pstate=active"]
        else if cpu.intel
        then ["intel_pstate=active"]
        else []
      )
      ++ ["ahci.mobile_lpm_policy=3"];
  };
}
