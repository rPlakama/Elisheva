{ pkgs, ... }:

{

  environment.gnome.excludePackages =
    (with pkgs; [
      baobab # disk usage analyzer
      geary # email reader
      gnome-tour # GNOME tour app
      yelp # help viewer
    ])
    ++ (with pkgs.gnome; [
      # Packages under the pkgs.gnome namespace
      gnome-calculator
      gnome-calendar
      gnome-characters
      gnome-clocks
      gnome-contacts
      gnome-font-viewer
      gnome-logs
      gnome-maps
      gnome-weather
    ]);
  environment.systemPackages = with pkgs; [
    btop-cuda
    bottles
    blender
    lutris
    heroic
    qbittorrent
  ];
}
