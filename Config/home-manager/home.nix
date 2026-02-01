{ pkgs, osConfig, ... }:
{
  imports = [
    ./default.nix
  ];
  programs = {
    fzf.enable = true;
    fish = {
      enable = true;
      shellInit = "
          function fish_greeting
end
fish_vi_key_bindings
";
      foot = {
        enable = osConfig.networking.hostName == "Centuria" || osConfig.networking.hostName == "Elisheva";
        settings = {
          main = {
            dpi-aware = false;
            font = "CaskaydiaCove Nerd Font Mono:size=9";
            include = "/home/rplakama/.config/foot/dank-colors.ini";
          };
        };
      };
    };
    mpv = {
      enable = osConfig.networking.hostName == "Centuria" || osConfig.networking.hostName == "Elisheva";
      scripts = with pkgs; [ mpvScripts.mpris ];

      config = {
        save-position-on-quit = true;
      };
    };
    yazi = {
      enable = true;
      enableFishIntegration = true;
      keymap = {
        mgr.prepend_keymap = [
          {
            run = "shell 'ripdrag -H 80 \"$@\" -x 2>/dev/null &' --confirm";
            on = [ "<C-n>" ];
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
  };
  home = {
    stateVersion = "25.05";
  };
}
