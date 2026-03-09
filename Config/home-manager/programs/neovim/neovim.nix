{ isDesktop, pkgs, inputs, ... }:

{
  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      base16-nvim
      nvim-lspconfig
      oil-nvim
      fzf-lua
      indent-blankline-nvim
      nvim-treesitter.withAllGrammars
      blink-cmp
    ];

    extraPackages = with pkgs; [
      nixd
      nixfmt
      fzf
      ripgrep
    ] ++ lib.optionals isDesktop [
      kotlin-language-server
      rust-analyzer
      lua-language-server
  ];

    extraLuaConfig = ''
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
