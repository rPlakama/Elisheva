{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ../../Features
  ];

  networking.hostName = "Elisheva";
  environment.systemPackages = with pkgs; [
    moonlight-qt
    ciscoPacketTracer9
    android-studio
    btop-rocm
  ];
  nixpkgs.config.android_sdk.accept_license = true;

  boot = {
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-x86_64-v3;
    kernelParams = [
      "video=eDP-1:1920x1080@72"
    ];
  };

  harwdare.bluetooth.enable = true;
  core.user = "rplakama";
  optionals.features = {
    neovim.enable = true;
    scx.enable = true;
    niri.enable = true;
    steam.enable = true;
    virtualization.enable = true;
  };
}
