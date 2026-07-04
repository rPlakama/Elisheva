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
    cpu.amd = true;
    git = {
      email = "rPlakama@proton.me";
      user = "rPlakama";
    };
  };
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v3;
  features = {
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
      output.vrr.enable = false;
    };
  };
}
