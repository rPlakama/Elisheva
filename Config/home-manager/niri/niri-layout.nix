{ ... }:
{
  programs.niri.settings = {
    layout = {
      gaps = 3;
      background-color = "00000000";
      center-focused-column = "never";
      preset-column-widths = [
        { proportion = 0.25; }
        { proportion = 0.5; }
        { proportion = 0.75; }
      ];
      struts = {
        bottom = 3;
        top = 3;
        left = 3;
        right = 3;
      };

      default-column-width.proportion = 0.5;
      focus-ring = {
        enable = false;
        width = 2;
      };
      border = {
        enable = true;
        inactive.color = "#95959519";
        active.color = "#101010ff";
        width = 2;
      };
      shadow = {
        enable = true;
        spread = 6;
        softness = 10;
        draw-behind-window = true;
      };
    };
  };
}
