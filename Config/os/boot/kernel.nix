{
  config,
  pkgs,
  ...
}: {
  boot = {
    kernelPackages =
      if config.networking.hostName == "Centuria"
      then pkgs.linuxPackages_cachyos
      else pkgs.linuxPackages_latest;
    kernelParams = [
      "amd_pstate=active"
    ];
  };
}
