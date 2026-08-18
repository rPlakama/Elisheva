{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  zram = config.core.zram;
in {
  config = mkIf (zram.enable) {
    zramSwap = {
      enable = true;
      algorithm = zram.algorithm;
      memoryMax = zram.size * 1024 * 1024;
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
