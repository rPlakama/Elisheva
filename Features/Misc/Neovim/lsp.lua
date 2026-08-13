-- Per-server tweaks (merges over nvim-lspconfig's built-in configs)
vim.lsp.config("lua_ls", {
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

vim.lsp.config("ts_ls", {
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

-- Enable every LSP server; servers without an installed binary are skipped.
vim.lsp.enable({
  "tinymist",
  "fish_lsp",
  "nixd",
  "nushell",
  "lua_ls",
  "rust_analyzer",
  "ts_ls",
  "clangd",
  "kotlin_language_server",
  "markdown_oxide",
})
