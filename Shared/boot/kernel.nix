{pkgs, ...}: {
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "amd_pstate=active"
      "video=eDP-1:1920x1080@75"
    ];
  };
}
