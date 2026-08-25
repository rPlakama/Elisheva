{
  config,
  lib,
  ...
}: let
  user = config.core.user;
  git = config.core.git;
in {
  hjem.users.${user} = {
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
}
