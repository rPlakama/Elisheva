local map = vim.keymap.set
local telescope = require('telescope')
local builtin = require('telescope.builtin')

-- Terminal
map('n', '<leader>t', '<cmd>sp term://fish<CR>', { desc = "Terminal" })

-- Telescope
telescope.setup({
	pickers = {
		find_files = {
			find_command = { "ag", "--silent", "--nocolor", "--follow", "--hidden", "--ignore", ".git", "-g", "" },
		},
	},
})

map('n', '<leader>f', builtin.find_files, { desc = 'Search files' })
map('n', '<leader>g', builtin.live_grep, { desc = 'Grep search' })
map('n', '<leader>a', builtin.buffers, { desc = 'Buffer search' })
map('n', '<leader>s', builtin.spell_suggest, { desc = 'Spell suggestions' })

-- Git signs
map('n', '<C-k>', '<cmd>Gitsigns toggle_current_line_blame<CR>', { desc = "Blame toggle" })
map('n', '<S-C-k>', '<cmd>Gitsigns blame_line<CR>', { desc = "Blame" })

-- Oil
map('n', '<C-n>', '<cmd>Oil<CR>', { desc = "Open Oil file explorer" })

-- Window navigation
map({ 'n', 't' }, '<A-h>', '<cmd>wincmd h<CR>', { desc = "Move to left window" })
map({ 'n', 't' }, '<A-l>', '<cmd>wincmd l<CR>', { desc = "Move to right window" })
map({ 'n', 't' }, '<A-j>', '<cmd>wincmd j<CR>', { desc = "Move to lower window" })
map({ 'n', 't' }, '<A-k>', '<cmd>wincmd k<CR>', { desc = "Move to upper window" })

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

-- LSP
map('n', 'K', function() vim.lsp.buf.hover() end, { desc = "Hover" })
map('n', '<leader>ca', function() vim.lsp.buf.code_action() end, { desc = "Code action" })
map('n', '<leader>rn', function() vim.lsp.buf.rename() end, { desc = "Rename symbol" })
map('n', 'gr', function() vim.lsp.buf.references() end, { desc = "References" })
map('n', '[d', function() vim.diagnostic.goto_prev() end, { desc = "Prev diagnostic" })
map('n', ']d', function() vim.diagnostic.goto_next() end, { desc = "Next diagnostic" })
map('n', '<leader>lf', function() vim.lsp.buf.format({ async = true }) end, { desc = "LSP Format buffer" })
map('n', 'gd', function() vim.lsp.buf.definition() end, { desc = "Go to definition" })
map('n', '<leader>d', function() vim.diagnostic.open_float() end, { desc = "Diagnostics float" })

-- Undo tree
map('n', '<leader>u', '<cmd>UndotreeToggle<CR>', { desc = "Undo tree" })

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

-- Esc to exit terminal insert mode
map('t', '<Esc>', '<C-\\><C-n>', { desc = "Exit terminal mode" })

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
