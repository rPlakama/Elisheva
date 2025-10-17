{ ... }:

{
  programs.niri.settings = {
    window-rules = [
      {
        matches = [ { is-focused = false; } ];
        opacity = 0.90;
      }
      {
        clip-to-geometry = true;
        geometry-corner-radius = {
          top-left = 7.0;
          top-right = 7.0;
          bottom-left = 7.0;
          bottom-right = 7.0;
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
