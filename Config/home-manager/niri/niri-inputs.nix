{
  osConfig,
  lib,
  ...
}:
{
  programs.niri.settings = {
    input = lib.mkMerge [
      {
        workspace-auto-back-and-forth = true;
        warp-mouse-to-focus.enable = true;
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

        mod-key = "Super";
        mod-key-nested = "Alt";
      }

      (lib.mkIf (osConfig.networking.hostName == "Centuria") {
        keyboard.xkb.layout = lib.mkForce "us";
        mod-key = lib.mkForce "Alt";
        mod-key-nested = lib.mkForce "Super";
      })
    ];
  };
}
