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
    niri.enable = true;
    neovim.enable = true;
    scx.enable = true;
    vesktop.enable = true;
  };
}
