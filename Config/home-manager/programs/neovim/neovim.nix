{
  isDesktop,
  pkgs,
  ...
}:

{
  programs.neovim = {
    enable = true;
    defaultEditor = isDesktop;
    viAlias = isDesktop;
    vimAlias = isDesktop;

    plugins = with pkgs.vimPlugins; [
      base16-nvim
      nvim-lspconfig
      fzf-lua
      indent-blankline-nvim
      nvim-treesitter.withAllGrammars
      blink-cmp
    ];

    extraPackages =
      with pkgs;
      [
        nixd
        nixfmt
        fzf
        ripgrep
      ]
      ++ lib.optionals isDesktop [
        kotlin-language-server
        rust-analyzer
        lua-language-server
        luaformatter
      ];

    initLua = ''
      require('configs')
      require('keybinds')
      require('lsp')
    '';
  };

  xdg.configFile = {
    "nvim/lua/configs.lua".source = ./configs.lua;
    "nvim/lua/keybinds.lua".source = ./keybinds.lua;
    "nvim/lua/lsp.lua".source = ./lsp.lua;
  };
}
