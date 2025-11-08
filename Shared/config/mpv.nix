{...}: {
  programs.mpv = {
    enable = true;
    config = {
      save-position-on-quit = true;
    };
  };
}
