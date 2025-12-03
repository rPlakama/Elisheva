{pkgs, ...}: {
  imports = [
    ./default.nix
  ];

  home.stateVersion = "25.05";
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.volantes-cursors;
    name = "volantes_light_cursors";
    size = 24;
  };
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };
  stylix.enable = true;
  stylix.targets = {
    gtk.enable = true;
    qt.enable = true;
    niri.enable = false;
  };
}
