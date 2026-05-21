{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ../../Features
  ];

  networking.hostName = "Arthoplerau";
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-zen4;

  hardware.bluetooth.enable = true;
  core.user = "rplakama";
  optionals.features = {
    neovim.enable = true;
    scx.enable = true;
    niri.enable = true;
    virtualization.enable = true;
  };
}
