{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.neovim;
  user = config.core.user;
  niriEnabled = config.features.niri.enable;

  base46Plugin = pkgs.vimUtils.buildVimPlugin {
    pname = "base46";
    version = "unstable-2025-04-25";
    doCheck = false;
    src = pkgs.fetchFromGitHub {
      owner = "AvengeMedia";
      repo = "base46";
      rev = "master";
      hash = "sha256-+FNEJBBa33onbq+BCQA1kO9dXDhGEUYbVIMnhrpr98U=";
    };
  };

  myNvim = pkgs.neovim.override {
    configure = {
      customRC = "luafile /home/${user}/.config/nvim/init.lua";
      packages.myPlugins.start =
        with pkgs.vimPlugins;
        [
          nvim-lspconfig
          fzf-lua
          nvim-treesitter.withAllGrammars
          blink-cmp
        ]
        ++ lib.optionals niriEnabled [ base46Plugin ];
    };
  };
in
{
  options.features.neovim.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Neovim Configuration";
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
      lua-language-server
      fish-lsp
      luaformatter
      nixd
      nixfmt
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
