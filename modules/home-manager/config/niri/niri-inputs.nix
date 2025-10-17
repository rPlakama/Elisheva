{...}: {
  programs.niri.settings = {
    input = {
      workspace-auto-back-and-forth = true;
      keyboard = {
        numlock = true;
        xkb = {
          layout = "br";
          options = "caps:swapescape";
        };
      };
      touchpad = {
        tap = true;
        dwt = true;
        scroll-method = "two-finger";
        accel-speed = 0.1;
        accel-profile = "adaptive";
      };
      mouse.accel-speed = -0.5;
    };
  };
}
