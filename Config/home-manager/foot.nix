{ ... }:
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        dpi-aware = false;
        font = "CaskaydiaCove Nerd Font Mono:size=9";
        include = "/home/rplakama/.config/foot/dank-colors.ini";
      };
    };
  };
}
