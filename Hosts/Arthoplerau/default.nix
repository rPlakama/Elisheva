{ inputs, pkgs, ... }:
{
  imports = [
    # ./hardware.nix
    ../../Features
    inputs.nixos-hardware.nixosModules.lenovo-ideapad-slim-5

  ];

  networking.hostName = "Arthoplerau";
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-zen4;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  core.user = "rplakama";
  features = {
    niri.enable = true;
    dankMaterialShell.enable = true;
    steam.enable = true;
    virtualization.enable = true;
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
