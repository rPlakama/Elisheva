{...}: {
  programs.niri.settings = {
    outputs = {
      "eDP-1" = {
        scale = 1.4;
        #background-color = "#050505aa";
        mode = {
          width = 1920;
          height = 1080;
          refresh = 74.986;
        };
      };
    };
  };
}
