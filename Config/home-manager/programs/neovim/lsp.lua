-- Blink
require('blink.cmp').setup({
  keymap = { preset = 'default' },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },
})

-- Lsp list
local capabilities = require('blink.cmp').get_lsp_capabilities()
local lsp_servers = {
  "rust_analyzer",
  "nixd",
  "lua-language-server",
  "kotlin_language_server"
}

-- Enabling
for _, server in ipairs(lsp_servers) do
  vim.lsp.enable(server, {
    capabilities = capabilities,
  })
end

-- Extras
vim.lsp.enable('nixd', {
  capabilities = capabilities,
  settings = {
    nixd = {
      nixpkgs = {
        expr = "import <nixpkgs> { }",
      },
      formatting = {
        command = { "nixpkgs-fmt" },
      },
    },
  },
})
