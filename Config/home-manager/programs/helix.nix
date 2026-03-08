{ ... }:

{

  programs.helix = {
    enable = true;
    settings = {
      theme = "gruvbox_dark_hard";
      editor = {
        soft-wrap.enable = true;
        mouse = false;
        indent-guides = {
          render = true;
          skip-levels = 1;
        };
      };
    };
  };
}
