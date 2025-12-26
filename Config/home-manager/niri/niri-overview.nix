{ ... }:
{
  programs.niri.settings = {
    overview = {
      workspace-shadow = {
        enable = true;
        spread = 300;
        softness = 300;
      };
    };
  };
}
