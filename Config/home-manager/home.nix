{ pkgs, ... }:
{
  imports = [
    ./default.nix
  ];

  home = {
    stateVersion = "25.05";
    pointerCursor = {
      package = pkgs.volantes-cursors;
      name = "volantes_light_cursors";
      size = 24;
      x11.enable = true;
    };
  };
}
