local opt = vim.opt
local o = vim.o

-- Leaders
vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.cmd.colorscheme("base16-chalk") -- I love this theme.

-- Base settings
opt.shortmess:append("I")
opt.expandtab = false
opt.shiftwidth = 2
opt.softtabstop = 2
opt.tabstop = 2
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.clipboard = "unnamedplus"
opt.cursorline = true
opt.mouse = ""
opt.wrap = true
opt.hlsearch = false
opt.incsearch = true
opt.autoindent = true
opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.undofile = true
opt.splitbelow = true
opt.splitright = true
o.winborder = "rounded"
o.exrc = true

-- Scrolloff dinâmico
opt.scrolloff = math.floor(o.lines / 2) - 3

-- Autocmds
vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function()
		vim.cmd([[%s/\s\+$//e]])
		vim.lsp.buf.format({ async = false })
	end,
})

vim.api.nvim_create_autocmd("VimResized", {
	desc = "Automatically resize splits when the host window is resized",
	group = vim.api.nvim_create_augroup("resize_splits", { clear = true }),
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})
-- Git sings config
require('gitsigns').setup {
	signs_staged_enable          = true,
	signcolumn                   = true, -- Toggle with `:Gitsigns toggle_signs`
	numhl                        = false, -- Toggle with `:Gitsigns toggle_numhl`
	linehl                       = false, -- Toggle with `:Gitsigns toggle_linehl`
	word_diff                    = false, -- Toggle with `:Gitsigns toggle_word_diff`
	watch_gitdir                 = {
		follow_files = true
	},
	auto_attach                  = true,
	attach_to_untracked          = false,
	current_line_blame           = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
	current_line_blame_opts      = {
		virt_text = true,
		virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
		delay = 1000,
		ignore_whitespace = false,
		virt_text_priority = 100,
		use_focus = true,
	},
	current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
	blame_formatter              = nil, -- Use default
	sign_priority                = 6,
	update_debounce              = 100,
	status_formatter             = nil,  -- Use default
	max_file_length              = 40000, -- Disable if file is longer than this (in lines)
	preview_config               = {
		style = 'minimal',
		relative = 'cursor',
		row = 0,
		col = 1
	},
}
-- Oil
require("oil").setup({
	default_file_explorer = true,
	columns = { "icon", "mtime" },
	buf_options = {
		buflisted = false,
		bufhidden = "hide",
	},
	win_options = {
		wrap = false,
		signcolumn = "no",
		cursorcolumn = true,
		foldcolumn = "0",
		spell = false,
		list = false,
		conceallevel = 3,
		concealcursor = "nvic",
	},
	delete_to_trash = false,
	skip_confirm_for_simple_edits = false,
	prompt_save_on_select_new_entry = true,
	cleanup_delay_ms = 2000,
	lsp_file_methods = {
		enabled = true,
		timeout_ms = 1000,
		autosave_changes = false,
	},
	constrain_cursor = "editable",
	watch_for_changes = false,
	use_default_keymaps = true,
	view_options = {
		show_hidden = true,
		is_hidden_file = function(name, bufnr)
			return name:match("^%.") ~= nil
		end,
		is_always_hidden = function(name, bufnr)
			return false
		end,
		natural_order = "fast",
		case_insensitive = false,
		sort = {
			{ "type", "asc" },
			{ "name", "asc" },
		},
		highlight_filename = function(entry, is_link_target, is_link_orphan)
			return nil
		end,
	},
})

require('blink.indent').setup({
	-- filetypes where scopes are closed by dedenting, such as python and yaml
	-- set to true to treat all filetypes this way
	dedent_scoped_filetypes = { include_defaults = true },
	blocked = {
		-- default: 'terminal', 'quickfix', 'nofile', 'prompt'
		buftypes = { include_defaults = true },
		-- default: 'lspinfo', 'packer', 'checkhealth', 'help', 'man', 'gitcommit', 'dashboard', ''
		filetypes = { include_defaults = true },
	},
	mappings = {
		-- which lines around the scope are included for 'ai': 'top', 'bottom', 'both', or 'none'
		border = 'both',
		-- set to '' to disable
		-- textobjects (e.g. `y2ii` to yank current and outer scope)
		object_scope = 'ii',
		object_scope_with_border = 'ai',
		-- motions
		goto_top = '[i',
		goto_bottom = ']i',
	},
	static = {
		enabled = true,
		char = '▎',
		whitespace_char = nil, -- inherits from `vim.opt.listchars:get().space` when `nil` (see `:h listchars`)
		priority = 1,
		-- specify multiple highlights here for rainbow-style indent guides
		-- highlights = { 'BlinkIndentRed', 'BlinkIndentOrange', 'BlinkIndentYellow', 'BlinkIndentGreen', 'BlinkIndentViolet', 'BlinkIndentCyan' },
		highlights = { 'BlinkIndent' },
	},
	scope = {
		enabled = true,         -- highlight highest level of indentation on the current line
		indent_at_cursor = false, -- clamp to indent level of cursor
		char = '▎',
		priority = 1000,
		-- set this to a single highlight, such as 'BlinkIndent' to disable rainbow-style indent guides
		-- highlights = { 'BlinkIndentScope' },
		-- optionally add: 'BlinkIndentRed', 'BlinkIndentCyan', 'BlinkIndentYellow', 'BlinkIndentGreen'
		highlights = { 'BlinkIndentOrange', 'BlinkIndentViolet', 'BlinkIndentBlue' },
		-- enable to show underlines on the line above the current scope
		underline = {
			enabled = false,
			-- optionally add: 'BlinkIndentRedUnderline', 'BlinkIndentCyanUnderline', 'BlinkIndentYellowUnderline', 'BlinkIndentGreenUnderline'
			highlights = { 'BlinkIndentOrangeUnderline', 'BlinkIndentVioletUnderline', 'BlinkIndentBlueUnderline' },
		},
	},
})
