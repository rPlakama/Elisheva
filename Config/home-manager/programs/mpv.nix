{ isDesktop, pkgs, ... }:
{
  programs.mpv = {
    enable = isDesktop;
    scripts = with pkgs; [ mpvScripts.mpris ];

    config = {
      save-position-on-quit = true;
    };
  };
}
