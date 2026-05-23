{ pkgs, ... }:
{
  imports = [
    # ./hardware.nix
    ../../Features
  ];

  networking.hostName = "Arthoplerau";
  boot = {
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-zen4;
    kernelParams = [ "amd_pstate=active" ]; # -- Useful for scx / ppd
  };

  hardware.bluetooth.enable = true;
  core.user = "rplakama";
  optionals.features = {
    niri = {
      enable = true;
      ppd.enable = true;
    };
    dankMaterialShell.enable = true;
    steam.enable = true;
    gpuScreenRecorder.enable = true;
    sunshine.enable = true;
    virtualization.enable = true;
    scx = {
      enable = true;
      scheduler = "scx_lavd";
      flags = [ "--autopower" ];
    };
    disko = {
      enable = true;
      dualDrive = true;
      primaryDrive = "/dev/nvme0n1"; # -- Placeholder
      secondaryDrive = "/dev/nvme1n1"; # -- Placeholder
      swap.enable = true;
    };
    preservation = {
      enable = true;
    };
  };
}
