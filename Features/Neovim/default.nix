{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.optionals.features.neovim;
  user = config.core.user;
  niriEnabled = config.optionals.features.niri.enable;
in
{
  options.optionals.features.neovim.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Neovim Configuration";
    default = true;
  };
  config = lib.mkIf cfg.enable {
    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      MANPAGER = "nvim +Man!";
    };
    environment.systemPackages = [
      (pkgs.neovim.override {
        configure = {
          customRC = ''
            luafile /home/${user}/.config/nvim/init.lua
          '';
          packages.myPlugins.start =
            with pkgs.vimPlugins;
            [
              nvim-lspconfig
              fzf-lua
              indent-blankline-nvim
              nvim-treesitter.withAllGrammars
              blink-cmp
            ]
            ++ lib.optionals niriEnabled [
              (pkgs.vimUtils.buildVimPlugin {
                name = "base46";
                doCheck = false;
                src = pkgs.fetchFromGitHub {
                  owner = "AvengeMedia";
                  repo = "base46";
                  rev = "master";
                  hash = "sha256-+FNEJBBa33onbq+BCQA1kO9dXDhGEUYbVIMnhrpr98U=";
                };
              })
            ];
        };
      })
    ];
    hjem.users.${user}.files = {
      ".config/nvim/lua/configs.lua".source = ./configs.lua;
      ".config/nvim/lua/lsp.lua".source = ./lsp.lua;
      ".config/nvim/lua/keybinds.lua".source = ./keybinds.lua;
      ".config/nvim/init.lua".text = ''
        require('configs')
        require('keybinds')
        require('lsp')
      ''
      + lib.optionalString niriEnabled ''
        vim.cmd.colorscheme("dms")
      '';

    };
  };
}
