{
  config,
  lib,
  ...
}: let
  feat = config.features.core;
  zram = config.core.zram;
in {
  config = lib.mkIf (feat.enable && zram.enable) {
    zramSwap = {
      enable = true;
      algorithm = zram.algorithm;
      memoryPercent = zram.memoryPercent;
      priority = zram.priority;
    };

    boot.kernel.sysctl = {
      "vm.swappiness" = zram.swappiness;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0;
    };
  };
}
