local opt = vim.opt

-- Base settings
opt.shortmess:append("I")
opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.tabstop = 2
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.clipboard = "unnamedplus"

-- Plugin Configs
require('base16-colorscheme').setup('chalk')
require("ibl").setup()

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    -- Save cursor position
    local save_cursor = vim.fn.getpos(".")
    -- Remove trailing whitespace
    vim.cmd([[%s/\s\+$//e]])

    vim.fn.setpos(".", save_cursor)
    vim.lsp.buf.format({ async = false })
  end,
})
