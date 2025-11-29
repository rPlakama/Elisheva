{pkgs, ...}: {
  programs.mpv = {
    enable = true;
    scripts = [pkgs.mpvScritps.mpris];
    config = {
      save-position-on-quit = true;
    };
  };
}
