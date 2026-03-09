local map = vim.keymap.set

-- Leader as space
vim.g.mapleader = " "

-- Fzf-lua search pickers
local fzf = require('fzf-lua')
fzf.setup({})
fzf.register_ui_select()

map('n', '<leader>f', fzf.files, { desc = "Search files" })
map('n', '<leader>g', fzf.live_grep, { desc = "Grep search" })
map('n', '<leader>a', fzf.buffers, { desc = "Buffer search" })
map('n', '<leader>s', fzf.spell_suggest, { desc = "Spell suggestions" })

-- Spell settings
map('n', '<C-M-1>', function()
  vim.opt.spell = true
  vim.opt.spelllang = 'en_us'
  print("Spell: English (US)")
end, { desc = "English spell check on" })

map('n', '<C-M-2>', function()
  vim.opt.spell = true
  vim.opt.spelllang = 'pt_br'
  print("Spell: Portuguese (BR)")
end, { desc = "Portuguese BR spell check on" })

map('n', '<C-M-3>', function()
  vim.opt.spell = false
  print("Spell: Off")
end, { desc = "Spell check off" })
