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
      hash = "sha256-dbVuQwFCOIBK9y7fklulxHHt57KbS/8KaiTvfe5rmco=";
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
  options.features.neovim = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Neovim Configuration";
    };
    extraInit = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional Lua lines to append to init.lua, declared by other features";
      example = [ "vim.opt.relativenumber = true" ];
    };
  };

  config = lib.mkIf cfg.enable {
    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      MANPAGER = "nvim +Man!";
    };

    environment.systemPackages = with pkgs; [
      # myNvim

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
      + "\n"
      + (lib.concatStringsSep "\n" cfg.extraInit);
    };
  };
}
