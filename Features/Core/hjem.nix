{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.features.core;
  user = config.core.user;
  git = config.core.git;
in
{
  config = mkIf cfg.enable {
    hjem.users.${user} = {
      enable = true;
      xdg.config.files = {
        "fish/config.fish".source = ./config.fish;
        "yazi/yazi.toml".source = ./yazi.toml;
        "yazi/keymap.toml".source = ./keymap.toml;
      };
      files.".gitconfig".text = ''
        [user]
        name = ${git.user}
        email = ${git.email}
      '';
    };
  };
}
