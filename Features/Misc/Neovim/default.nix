{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.neovim;
  user = config.core.user;
  headless = config.core.headless;
  theming = config.features.theming;
  inherit (lib) optionals;

  theme = if theming.enable then theming.base16Theme else "chalk";

  myNvim = pkgs.neovim.override {
    configure = {
      customRC = "luafile ~/.config/nvim/init.lua";
      packages.myPlugins.start = with pkgs.vimPlugins; [
        nvim-lspconfig
        nvim-treesitter.withAllGrammars
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

  baseServers = [
    "tinymist"
    "fish_lsp"
    "nixd"
    "nushell"
    "lua_ls"
  ];

  heavyServers = [
    "rust_analyzer"
    "ts_ls"
    "clangd"
    "kotlin_language_server"
    "markdown_oxide"
  ];

  lspServers = baseServers ++ lib.optionals (!headless) heavyServers;

  lspList = lib.concatMapStringsSep ",\n    " (s: ''"${s}"'') lspServers;

  lspLua = ''
    require("blink.cmp").setup({
      keymap = { preset = "default" },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
    })

    vim.lsp.enable({
      ${lspList},
    })

    vim.lsp.enable("lua_ls", {
      settings = {
        Lua = {
          format = {
            enable = true,
            defaultConfig = {
              indent_style = "space",
              indent_size = "2",
            },
          },
        },
      },
    })

    ${lib.optionalString (!headless) ''
      vim.lsp.enable("ts_ls", {
        root_dir = vim.fs.root(0, { "tsconfig.json", "package.json", ".git" }),
        settings = {
          typescript = {
            format = {
              enable = true,
            },
          },
          javascript = {
            format = {
              enable = true,
            },
          },
        },
      })

      vim.lsp.enable("kotlin_language_server", {
        root_dir = vim.fs.root(0, { "build.gradle", "build.gradle.kts", ".git" }),
      })
    ''}
  '';
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

    environment.systemPackages =
      with pkgs;
      [
        myNvim
        tinymist
        lua-language-server
        fish-lsp
        nixd
        nushell
      ]
      ++ optionals (!headless) [
        markdown-oxide
        typescript-language-server
        clang-tools
        kotlin-language-server
        rust-analyzer
        rustc
        cargo
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
        "nvim/lua/lsp.lua".text = lspLua;
        "nvim/lua/plugins.lua".source = ./plugins.lua;
      };
    };
  };
}
