{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Security
    age
    sops
    # Visuals
    papirus-folders
    papirus-icon-theme
    volantes-cursors
    # Graphical Applications
    firefox
    vesktop
    materialgram
    # General Tools
    nautilus
    lorien
    papers
    loupe
    # Others
    distrobox
    typst
    xwayland-satellite

  ];
}
