{...}: {
  programs.niri.settings = {
    window-rules = [
      {
        matches = [{is-focused = false;}];
        opacity = 0.95;
      }
      {
        clip-to-geometry = true;
        geometry-corner-radius = {
          top-left = 0.0;
          top-right = 0.0;
          bottom-left = 0.0;
          bottom-right = 0.0;
        };
      }
      {
        matches = [
          {
            app-id = "firefox$";
            title = "^Picture-in-Picture$";
          }
        ];
        open-floating = true;
      }
    ];
  };
}
