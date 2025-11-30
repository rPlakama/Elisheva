{...}: {
  programs.niri.settings = {
    overview = {
      workspace-shadow = {
        enable = true;
        spread = 10;
        softness = 100;
      };
    };
  };
}
