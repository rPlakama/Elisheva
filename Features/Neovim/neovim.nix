{
  isDesktop,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.optionals.features.neovim;
  user = config.core.user;

in

{
  options.optionals.features.neovim.enable = lib.mkEnableOption {
    type = lib.types.bool;
    description = "Neovim Configuration";
    default = true;
  };
  config = lib.mkIf cfg.enable {
    home-manager.${user} = {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;

        plugins =
          with pkgs.vimPlugins;
          [
            nvim-lspconfig
            fzf-lua
            indent-blankline-nvim
            nvim-treesitter.withAllGrammars
            blink-cmp

          ]
          ++ lib.optionals isDesktop [
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

        extraPackages = with pkgs; [
          nixd
          nixfmt
          ripgrep
          lua-language-server
          luaformatter

          fish-lsp
        ];

        initLua = ''
          require('configs')
          require('keybinds')
          require('lsp')
        ''
        + lib.optionalString isDesktop ''
          vim.cmd.colorscheme("dms")
        '';
      };

      xdg.configFile = {
        "nvim/lua/configs.lua".source = ./configs.lua;
        "nvim/lua/keybinds.lua".source = ./keybinds.lua;
        "nvim/lua/lsp.lua".source = ./lsp.lua;
      };
    };
  };
}
