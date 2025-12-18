{
  lib,
  config,
  pkgs,
  ...
}:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "amd_pstate=active"
    ]
    ++ lib.optionals (config.networking.hostName == "Elisheva") [
      "video=eDP-1:1920x1080@75"
    ];
  };
}
