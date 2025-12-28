{ lib, osConfig, ... }:
{
  programs.niri.settings = lib.mkMerge [
    {
      input = {
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

        # Default for most hosts
        mod-key = "Super";
        mod-key-nested = "Alt";
      };
    }

    # 2. Host-specific Override (Applied only to Centuria)
    (lib.mkIf (osConfig.networking.hostName == "Centuria") {
      input.mod-key = lib.mkForce "Alt";
    })
  ];
}
