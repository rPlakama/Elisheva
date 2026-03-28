{ ... }:
{
  programs = {
    fish = {
      enable = true;
      shellInit = builtins.readFile ./shellInit.fish;
    };
    yazi = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        mgr.show_hidden = true;
        opener.edit = [
          {
            run = "nvim \"$@\"";
            block = true;
          }
        ];
      };
      keymap.mgr.prepend_keymap = [
        {
          on = [ "<C-n>" ];
          run = "shell 'ripdrag -H 80 \"$@\" -x 2>/dev/null &' --confirm";
        }
      ];
    };

  };
}
