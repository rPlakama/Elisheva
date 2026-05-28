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
    lutris
  ];
  core.user = "rplakama";
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-x86_64-v3;
  features.nvidia.enable = true;
  features = {
    gpuScreenRecorder.enable = true;
    virtualization.enable = true;
    sunshine.enable = true;
    steam.enable = true;
    qbit.enable = true;
    bootloader.nixos-init.enable = true;
    scx = {
      enable = true;
      flags = [ "--performance" ];
    };

    niri = {
      keyboardLayout = "br,us";
      enable = true;
    };

  };
}
