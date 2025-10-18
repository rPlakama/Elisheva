{...}: {
  programs.niri.settings = {
    layout = {
      gaps = 3;
      background-color = "00000000";
      center-focused-column = "never";
      preset-column-widths = [
        {proportion = 0.33333;}
        {proportion = 0.5;}
        {proportion = 0.66667;}
      ];
      struts = {
        bottom = 6;
        top = 6;
        left = 12;
        right = 12;
      };

      default-column-width.proportion = 0.4;
      focus-ring = {
        enable = false;
        width = 2;
      };
      border = {
        enable = true;
        active.color = "#f5f5f519";
        inactive.color = "#101010ff";
        width = 2;
      };
      shadow = {
        enable = true;
        spread = 15;
        softness = 20;
        draw-behind-window = true;
      };
    };
  };
}
