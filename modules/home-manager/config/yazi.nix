# -- Yazi Configuration -- #
{...}: {
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    keymap = {
      mgr.prepend_keymap = [
        {
          run = "shell 'ripdrag -H 80 \"$@\" -x 2>/dev/null &' --confirm";
          on = ["<C-n>"];
        }
      ];
    };
    settings = {
      mgr = {
        show_hidden = true;
      };
      opener.edit = [
        {
          run = "nvim \"$@\"";
          block = true;
        }
      ];
    };
  };
}
