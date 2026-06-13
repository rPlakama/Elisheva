{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ../../Features
  ];

  networking.hostName = "Centuria";

  environment.systemPackages = with pkgs; [
    ckan
  ];
  core = {
    user = "rplakama";
    gpu.nvidia = true;
    git = {
      email = "rPlakama@proton.me";
      user = "rPlakama";
    };
  };
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
  features = {
    gpuScreenRecorder.enable = true;
    virtualization.enable = true;
    sunshine.enable = true;
    gaming = {
      enable = true;
      gsr.enable = true;
    };
    qbit.enable = true;
    bootloader.nixos-init.enable = true;
    niri = {
      keyboardLayout = "br,us";
      enable = true;
      NoctaliaEnabled = true;
    };
  };
}
