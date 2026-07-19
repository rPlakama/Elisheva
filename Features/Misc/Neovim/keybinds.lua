local map = vim.keymap.set
local opt = vim.opt

-- Keymaps
-- Terminal
map('n', '<leader>t', '<cmd>sp term://fish<CR>') -- We use fish here, but that should be a line substitution like in Niri;


-- / fzf
local fzf = require('fzf-lua')
map('n', '<leader>f', fzf.files, { desc = "Search files" })
map('n', '<leader>g', fzf.live_grep, { desc = "Grep search" })
map('n', '<leader>a', fzf.buffers, { desc = "Buffer search" })
map('n', '<leader>s', fzf.spell_suggest, { desc = "Spell suggestions" })

-- Git Sings
map('n', '<C>k', '<cmd>Gitsings toggle_current_line_blame<CR>', { desc = 'Blame toggle' })
map('n', '<S-C>j', '<cmd>Gitsings blame<CR>', { desc = 'Blame toggle' })

-- Oil
map('n', '<C-n>', '<cmd>Oil<CR>', { desc = "Open Oil file explorer" })

-- Window navigation
map({ 'n', 't' }, '<A-h>', '<cmd>wincmd h<CR>', { desc = 'Move to left window' })
map({ 'n', 't' }, '<A-l>', '<cmd>wincmd l<CR>', { desc = 'Move to right window' })
map({ 'n', 't' }, '<A-j>', '<cmd>wincmd j<CR>', { desc = 'Move to lower window' })
map({ 'n', 't' }, '<A-k>', '<cmd>wincmd k<CR>', { desc = 'Move to upper window' })

-- Spell settings
map('n', '<C-M-1>', function()
	opt.spell = true
	opt.spelllang = 'en_us'
	print("Spell: English (US)")
end, { desc = "English spell check on" })
map('n', '<C-M-2>', function()
	opt.spell = true
	opt.spelllang = 'pt_br'
	print("Spell: Portuguese (BR)")
end, { desc = "Portuguese BR spell check on" })
map('n', '<C-M-3>', function()
	opt.spell = false
	print("Spell: Off")
end, { desc = "Spell check off" })

-- LSP
map('n', '<leader>lf', function() vim.lsp.buf.format({ async = true }) end, { desc = "LSP Format buffer" })
map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', { desc = "Go to definition" })
map('n', '<leader>d', '<cmd>lua vim.diagnostic.open_float()<CR>', { desc = "Diagnostics float" })

-- Buffer
map('n', '<leader>bd', function()
	vim.cmd("bd")
	vim.cmd("echo 'Buffer deleted'")
end, { desc = "Delete buffer" })

-- Remove accidental command window
map('n', 'q:', ':')

-- Smart i/a/A on blank lines
for _, bind in ipairs({ "i", "a", "A" }) do
	map("n", bind, function()
		if vim.fn.getline("."):match("^%s*$") then
			return [["_cc]]
		else
			return bind
		end
	end, { expr = true, noremap = true, silent = true })
end

-- C-Backspace deletes whole word in insert mode
map('i', '<C-BS>', '<C-W>', { desc = "Delete word" })

-- Flash
map('n', 'ss', function() require("flash").jump() end, { desc = "Flash jump" })
map('n', 'S', function() require("flash").treesitter() end, { desc = "Flash treesitter" })
map('n', '<leader>r', function() require("flash").remote() end, { desc = "Flash remote" })
map('n', '<leader>R', function() require("flash").treesitter_search() end, { desc = "Flash treesitter search" })

-- Tabs
map('n', '<C-T>l', function() vim.cmd("tabnext") end, { desc = "Next tab" })
map('n', '<C-T>h', function() vim.cmd("tabprevious") end, { desc = "Prev tab" })
map('n', '<C-T>j', function() vim.cmd("tabnew") end, { desc = "New tab" })
map('n', '<C-T>q', function() vim.cmd("tabclose") end, { desc = "Close tab" })
