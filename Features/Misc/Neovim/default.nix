{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.neovim;
  user = config.core.user;
  theming = config.features.theming;

  theme = if theming.enable then theming.base16Theme else "chalk";

  myNvim = pkgs.neovim.override {
    configure = {
      customRC = "luafile ~/.config/nvim/init.lua";
      packages.myPlugins.start = with pkgs.vimPlugins; [
        nvim-lspconfig
        nvim-treesitter.withAllGrammars
        fff-nvim
        fzf-lua
        blink-cmp
        oil-nvim
        flash-nvim
        base16-nvim
        gitsigns-nvim
        blink-indent
        mini-icons
        mini-clue
        mini-comment
        mini-surround
        mini-pairs
        mini-trailspace
        mini-hipatterns
        undotree
      ];
    };
  };

in
{
  options.features.neovim = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Neovim Configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      MANPAGER = "nvim +Man!";
    };

    environment.systemPackages = with pkgs; [
      myNvim
      tinymist
      lua-language-server
      fish-lsp
      nixd
      nushell
      silver-searcher-ng
    ];

    hjem.users.${user} = {
      packages = with pkgs; [
        typst
        nixfmt
      ];

      xdg.config.files = {
        "nvim/init.lua".text = ''
          require('configs')
          require('keybinds')
          require('lsp')
          require('plugins')
          vim.cmd.colorscheme("base16-${theme}")
        '';
        "nvim/lua/configs.lua".source = ./configs.lua;
        "nvim/lua/keybinds.lua".source = ./keybinds.lua;
        "nvim/lua/lsp.lua".source = ./lsp.lua;
        "nvim/lua/plugins.lua".source = ./plugins.lua;
      };
    };
  };
}
