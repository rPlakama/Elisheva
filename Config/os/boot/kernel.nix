{
  lib,
  config,
  pkgs,
  ...
}: {
  boot = {
    kernelPackages =
      if config.networking.hostName == "Centuria"
      then pkgs.linuxPackages_cachyos
      else pkgs.linuxPackages_latest;
    kernelParams =
      [
        "amd_pstate=active"
      ]
      ++ lib.optionals (config.networking.hostName == "Elisheva") [
        "rcutree.enable_rcu_lazy=1"
        "video=eDP-1:1920x1080@75"
      ];
  };
}
