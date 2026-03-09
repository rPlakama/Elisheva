{ pkgs, inputs, ... }:

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
      fzf-lua
      indent-blankline-nvim
      nvim-treesitter.withAllGrammars
      blink-cmp
    ];

    extraPackages = with pkgs; [
      nixd
      nixpkgs-fmt
      rust-analyzer
      kotlin-language-server
      fzf 
      ripgrep
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
