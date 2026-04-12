{ pkgs, ... }:

{

  environment.gnome.excludePackages = (
    with pkgs;
    [
      baobab
      geary
      gnome-tour
      yelp
      gnome-weather
      gnome-maps
      gnome-contacts
      gnome-clocks
    ]
  );
  environment.systemPackages = with pkgs; [
    btop-cuda
    bottles
    blender
    lutris
    heroic
    qbittorrent
  ];
}
