{ isDesktop, ... }:
{
  programs = {
    fzf.enable = true;
    fish = {
      enable = true;
      shellInit = builtins.readFile ./shellInit.fish;
    };
    foot = {
      enable = isDesktop;
      settings.main = {
        dpi-aware = false;
        font = "CaskaydiaCove Nerd Font Mono:size=9";
        include = "/home/rplakama/.config/foot/dank-colors.ini";
      };
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
