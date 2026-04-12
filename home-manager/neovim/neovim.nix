{
  isElisheva,
  lib,
  pkgs,
  ...
}:

{
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
      ++ lib.optionals isElisheva [
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

    extraPackages =
      with pkgs;
      [
        nixd
        nixfmt
        ripgrep
        lua-language-server
        fish-lsp
      ]
      ++ lib.optionals isDesktop [
        kotlin-language-server
        rust-analyzer
        lua-language-server
        luaformatter
        tinymist
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
}
