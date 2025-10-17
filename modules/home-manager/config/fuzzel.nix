{
  lib,
  pkgs,
  ...
}:
{
  # -- Fuzzel -- #
  programs.tofi = {
    enable = true;
    settings = {
      terminal = "foot";
    };
  };
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "${pkgs.foot}/bin/foot -e";
        icons-enabled = false;
        anchor = "top";
        lines = 1;
	width = 150;
      };
      border = {
        selection-radius = 0;
        radius = 0;
        width = 0;
      };
     colors.selection = lib.mkForce "#101010ff";
    };
  };
}
