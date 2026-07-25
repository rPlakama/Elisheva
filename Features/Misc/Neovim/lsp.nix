{ lib, ... }:
{
  plugins = {
    blink-cmp = {
      enable = true;
      settings = {
        keymap = {
          preset = "default";
        };
        sources = {
          default = [
            "lsp"
            "path"
            "snippets"
            "buffer"
          ];
        };
      };
    };

    lsp = {
      enable = true;
      servers = {
        rust_analyzer = {
          enable = true;
          installCargo = false;
          installRustc = false;
        };
        tinymist.enable = true;
        ts_ls = {
          enable = true;
          extraOptions = {
            root_dir = lib.nixvim.mkRaw ''vim.fs.root(0, { "tsconfig.json", "package.json", ".git" })'';
            settings = {
              typescript = {
                format = {
                  enable = true;
                };
              };
              javascript = {
                format = {
                  enable = true;
                };
              };
            };
          };
        };
        fish_lsp.enable = true;
        nixd.enable = true;
        nushell.enable = true;
        lua_ls = {
          enable = true;
          settings = {
            Lua = {
              format = {
                enable = true;
                defaultConfig = {
                  indent_style = "space";
                  indent_size = "2";
                };
              };
            };
          };
        };
        clangd.enable = true;
        kotlin_language_server = {
          enable = true;
          extraOptions = {
            root_dir = lib.nixvim.mkRaw ''vim.fs.root(0, { "build.gradle", "build.gradle.kts", ".git" })'';
          };
        };
        markdown_oxide.enable = true;
      };
    };
  };
}
