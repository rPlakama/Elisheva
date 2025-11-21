{...}: {
  programs.niri.settings = {
    layout = {
      gaps = 3;
      background-color = "00000000";
      center-focused-column = "never";
      preset-column-widths = [
        {proportion = 0.2;}
        {proportion = 0.33333;}
        {proportion = 0.5;}
        {proportion = 0.66667;}
        {proportion = 0.8;}
      ];
      struts = {
        bottom = 3;
        top = 3;
        left = 6;
        right = 6;
      };

      default-column-width.proportion = 0.4;
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
