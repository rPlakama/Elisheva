{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ../../Features
    inputs.nixos-hardware.nixosModules.lenovo-ideapad-slim-5

  ];

  networking.hostName = "Arthoplerau";
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-zen4;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  core = {
    user = "rplakama";
    git = {
      email = "rPlakama@proton.me";
      user = "rPlakama";
    };
  };
  services = {
    tlp.enable = false;
    fwupd.enable = true;
  };
  features = {
    niri.enable = true;
    dankMaterialShell.enable = true;
    steam.enable = true;
    virtualization.enable = true;
    disko = {
      enable = true;
      dualDrive = true;
      primaryDrive = "/dev/nvme1n1";
      secondaryDrive = "/dev/nvme0n1";
      swap.enable = true;
    };
    preservation = {
      enable = true;
    };
  };
}
