{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ../../Features
  ];

  networking.hostName = "Centuria";

  environment.systemPackages = with pkgs; [
    ckan
    winetricks
    cabextract
    wine
    btop-cuda
  ];
  core = {
    user = "rplakama";
    git = {
      email = "rPlakama@proton.me";
      user = "rPlakama";
    };
  };
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
  features.nvidia.enable = true;
  features = {
    gpuScreenRecorder.enable = true;
    virtualization.enable = true;
    sunshine.enable = true;
    steam.enable = true;
    qbit.enable = true;
    bootloader.nixos-init.enable = true;
    niri = {
      keyboardLayout = "br,us";
      enable = true;
      DMSEnabled = true;
    };
  };
}
