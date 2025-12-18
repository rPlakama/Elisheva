{ ... }:
{
  programs.niri.settings = {
    window-rules = [
      {
        matches = [ { is-focused = false; } ];
        opacity = 1.0;
      }
      {
        clip-to-geometry = true;
        geometry-corner-radius = {
          top-left = 4.0;
          top-right = 4.0;
          bottom-left = 4.0;
          bottom-right = 4.0;
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
