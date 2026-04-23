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
  ];

  boot = {
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-x86_64-v3;
    kernelParams = [
      "video=eDP-1:1920x1080@72"
    ];
  };

  core.user = "rplakama";
  optionals.features = {
    neovim.enable = true;
    scx.enable = true;
    niri.enable = true;
  };
}
