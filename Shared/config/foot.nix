# -- Foot Terminal -- #
{...}: {
  # -- Terminal -- #
  programs.foot.enable = true;
  # -- Shell -- #
  programs.bash = {
    enable = true;
    bashrcExtra = "
    set -o vi
    set vi-ins-mode-string \1\e[6 q\2
    set vi-cmd-mode-string \1\e[2 q\2
    ";
  };
}
