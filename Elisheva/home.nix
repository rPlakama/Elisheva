{
  inputs,
  pkgs,
  ...
}: {
  # -- Core Home Manager Settings -- #
  imports = [
    ./home-manager/config
  ];

  home.stateVersion = "25.05";
  # -- Theming & Appearance -- #
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

  # -- Stylix -- #
  stylix.enable = true;
  stylix.targets = {
    gtk.enable = true;
    qt.enable = true;
    niri.enable = false;
    zen-browser.profileNames = [
      "my-profile"
    ];
  };
}
