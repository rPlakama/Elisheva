{ pkgs, ... }:

{
  programs = {
    mpv = {
      enable = true;
      scripts = with pkgs; [ mpvScripts.mpris ];
      config = {
        save-position-on-quit = true;
      };
    };
    foot = {
      enable = true;
      settings.main = {
        dpi-aware = true;
        font = "CaskaydiaCove Nerd Font Mono:size=9";
        include = "/home/rplakama/.config/foot/dank-colors.ini";
      };
    };
  };
}
