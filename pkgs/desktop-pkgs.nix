{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    age
    sops
    papirus-folders
    papirus-icon-theme
    firefox
    vesktop
    materialgram
    jellyfin-desktop
    volantes-cursors
    distrobox
    nautilus
    lorien
    evince
    xwayland-satellite
  ];
}
