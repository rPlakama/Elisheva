{...}: {
  programs.niri.settings = {
    overview = {
      workspace-shadow = {
        enable = true;
        spread = 5;
        softness = 100;
      };
    };
  };
}
