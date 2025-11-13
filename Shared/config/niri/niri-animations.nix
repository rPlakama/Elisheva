{...}: {
  programs.niri.settings = {
    animations = let
      anim = {
        enable = true;
        kind.easing = {
          duration-ms = 500;
          curve = "cubic-bezier";
          curve-args = [
            0
            1
            0
            1
          ];
        };
      };
    in {
      slowdown = 1.0;
      workspace-switch = anim;
      overview-open-close = anim;
      horizontal-view-movement = anim;
      window-movement = anim;
      window-resize = anim;
      window-open = anim;
      window-close = anim;
    };
  };
}
