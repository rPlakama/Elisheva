{
  config,
  lib,
  ...
}:
let
  cfg = config.features.core;
  user = config.core.user;
in
{
  config = lib.mkIf cfg.enable {
    hjem.users.${user} = {
      enable = true;
      xdg.config.files = {
        "fish/config.fish".source = ./config.fish;
        "yazi/yazi.toml".source = ./yazi.toml;
        "yazi/keymap.toml".source = ./keymap.toml;
      };
      files.".gitconfig".text = ''
        [user]
        name = ${config.core.git.user}
        email = ${config.core.git.email}
      '';
    };
  };
}
