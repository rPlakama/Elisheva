# -- Foot Terminal -- #
{...}: {
  # -- Terminal -- #
  programs.foot.enable = true;
  # -- Shell -- #
  programs.bash = {
    enable = true;
    bashrcExtra = "
    set -o vi
    eval '$(zoxide init posix --hook prompt)'
    ";
  };
}
