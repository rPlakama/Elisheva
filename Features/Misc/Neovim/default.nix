{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.neovim;
  user = config.core.user;

  myNvim = pkgs.neovim.override {
    configure = {
      customRC = "luafile /home/${user}/.config/nvim/init.lua";
      packages.myPlugins.start = with pkgs.vimPlugins; [
        nvim-lspconfig
        fzf-lua
        nvim-treesitter.withAllGrammars
        blink-cmp
        oil-nvim
        flash-nvim
        base16-nvim
        gitsigns-nvim
      ];
    };
  };
in
{
  options.features.neovim = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Neovim Configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      MANPAGER = "nvim +Man!";
    };

    environment.systemPackages = with pkgs; [
      myNvim
      tinymist
      typst
      lua-language-server
      fish-lsp
      luaformatter
      nixd
      nixfmt
      markdown-oxide
    ];

    hjem.users.${user}.files = {
      ".config/nvim/lua/configs.lua".source = ./configs.lua;
      ".config/nvim/lua/lsp.lua".source = ./lsp.lua;
      ".config/nvim/lua/keybinds.lua".source = ./keybinds.lua;
      ".config/nvim/init.lua".text = ''
        require('configs')
        require('keybinds')
        require('lsp')
      '';
    };
  };
}
