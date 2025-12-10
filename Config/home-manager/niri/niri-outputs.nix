{ ... }:
{
  programs.niri.settings = {
    outputs = {
      "eDP-1" = {
        scale = 1.4;
        mode = {
          width = 1920;
          height = 1080;
          refresh = 74.986;
        };
      };
      "HDMI-A-1" = {
        scale = 1.0;
        position = {
          x = 0;
          y = 0;
        };
      };
    };
  };
}
