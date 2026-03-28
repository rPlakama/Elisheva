{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    btop-cuda
    bottles
    blender
    lutris
    qbittorrent
  ];
}
