-- Blink
require('blink.cmp').setup({
  keymap = { preset = 'default' },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },
})

vim.lsp.enable({
  "rust_analyzer",
  "nixd",
  "lua-language-server",
  "kotlin_language_server"
})

vim.lsp.enable('nixd', {
  capabilities = capabilities,
  settings = {
    nixd = {
      nixpkgs = {
        expr = "import <nixpkgs> { }",
      },
      formatting = {
        command = { "nixfmt" },
      },
    },
  },
})
