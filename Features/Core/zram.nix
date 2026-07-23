{
  config,
  lib,
  ...
}: let
  cfg = config.features.core;
in {
  config = lib.mkIf (cfg.enable && cfg.zram.enable) {
    zramSwap = {
      enable = true;
      algorithm = cfg.zram.algorithm;
      memoryPercent = cfg.zram.memoryPercent;
      priority = cfg.zram.priority;
    };

    boot.kernel.sysctl = {
      "vm.swappiness" = cfg.zram.swappiness;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0;
    };
  };
}
