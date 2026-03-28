{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    age
    sops
    papirus-folders
    papirus-icon-theme
    firefox
    materialgram
    volantes-cursors
    distrobox
    nautilus
  ];
}
