{ pkgs, ...}:

{
    boot.kernelPackages = pkgs.linuxPackages_cachyos;
    boot.kernelParams = [
    "rcutree.enable_rcu_lazy=1"
    "video=eDP-1:1920x1080@75"
  ];
}


