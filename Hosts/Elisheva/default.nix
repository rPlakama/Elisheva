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
  boot.kernelParams = [
    "video=eDP-1:1920x1080@72"
  ];

  core.user = "rplakama";
  optionals.features = {
    neovim.enable = true;
    scx.enable = true;
    niri.enable = true;
  };
}
