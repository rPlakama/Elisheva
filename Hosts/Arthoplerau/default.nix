{ pkgs, ... }:
{
  imports = [
    # ./hardware.nix
    ../../Features
  ];

  networking.hostName = "Arthoplerau";
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-zen4;

  hardware.bluetooth.enable = true;
  core.user = "rplakama";
  optionals.features = {
    scx.enable = true;
    niri.enable = true;
    virtualization.enable = true;
    disko = {
      enable = true;
      dualDrive = true;
      primaryDrive = "/dev/nvme0n1p1"; # -- Placeholder
      secondaryDrive = "/dev/nvme0n1p2"; # -- Placeholder
    };
    preservation = {
      additionalHomeDirs = [
        ".config/vesktop" # -- Imma not doing it manually
        ".config/niri" # -- Cause 'dms generated files
      ];
    };
  };
}
