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
  "lua_ls",
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

vim.lsp.enable('kotlin_language_server', {
  capabilities = capabilities,
  root_dir = vim.fs.root(0, { 'build.gradle', 'build.gradle.kts', '.git' }),
  settings = {
  },
})
