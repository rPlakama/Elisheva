{...}: {
  programs.niri.settings = {
    layout = {
      gaps = 3;
      background-color = "00000000";
      center-focused-column = "never";
      preset-column-widths = [
        {proportion = 0.22222;}
        {proportion = 0.33333;}
        {proportion = 0.6666;}
        {proportion = 0.9999;}
      ];
      struts = {
        bottom = 3;
        top = 3;
        left = 6;
        right = 6;
      };

      default-column-width.proportion = 0.3333;
      focus-ring = {
        enable = false;
        width = 2;
      };
      border = {
        enable = true;
        inactive.color = "#f5f5f519";
        active.color = "#101010ff";
        width = 2;
      };
      shadow = {
        enable = true;
        spread = 3;
        softness = 10;
        draw-behind-window = true;
      };
    };
  };
}
