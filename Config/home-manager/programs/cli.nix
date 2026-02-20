{ osConfig, ... }:
{
  programs = {
    fzf.enable = true;
    fish = {
      enable = true;
      shellInit = ''
                function fish_greeting
                end
                fish_vi_key_bindings
        	function fish_prompt
            set -l nix_indicator ""

            if set -q IN_NIX_SHELL
                if test "$IN_NIX_SHELL" = pure
                    set nix_indicator (set_color green)" pure "(set_color normal)
                else
                    set nix_indicator (set_color blue)" nix "(set_color normal)
                end
            else if set -q DIRENV_DIR
                set nix_indicator (set_color cyan)" direnv "(set_color normal)
            end

            echo -s (whoami) "@" (hostname) " " (date '+%H:%M') " " (set_color yellow) (prompt_pwd) (set_color normal) " " $nix_indicator

            echo -n "> "
        end
      '';
    };

    foot = {
      enable = osConfig.networking.hostName == "Centuria" || osConfig.networking.hostName == "Elisheva";
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
