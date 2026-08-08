local opt = vim.opt
local o = vim.o

-- Leaders
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Base settings
opt.expandtab = false
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
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
opt.undodir = vim.fn.stdpath("data") .. "/undo"
vim.fn.mkdir(vim.fn.stdpath("data") .. "/undo", "p")
opt.undofile = true
opt.splitbelow = true
opt.splitright = true
o.winborder = "rounded"
o.exrc = true

opt.shortmess:append("I")
opt.scrolloff = math.max(math.floor(o.lines / 2) - 3, 0)

-- Autocmds
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    -- Skip while a mini.snippets session is active: rewriting lines deletes
    -- the session's extmarks and corrupts it (breaks buffer loading).
    if _G.MiniSnippets and MiniSnippets.session.get(false) ~= nil then return end
    MiniTrailspace.trim()
    pcall(vim.lsp.buf.format, { async = false })
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
  signcolumn                   = true,
  numhl                        = false,
  linehl                       = false,
  word_diff                    = false,
  watch_gitdir                 = {
    follow_files = true
  },
  auto_attach                  = true,
  attach_to_untracked          = false,
  current_line_blame           = false,
  current_line_blame_opts      = {
    virt_text = true,
    virt_text_pos = 'eol',
    delay = 1000,
    ignore_whitespace = false,
    virt_text_priority = 100,
    use_focus = true,
  },
  current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
  sign_priority                = 6,
  update_debounce              = 100,
  max_file_length              = 40000,
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
  },
})

-- Blink indent
require('blink.indent').setup({
  dedent_scoped_filetypes = { include_defaults = true },
  blocked = {
    buftypes = { include_defaults = true },
    filetypes = { include_defaults = true },
  },
  mappings = {
    border = 'both',
    object_scope = 'ii',
    object_scope_with_border = 'ai',
    goto_top = '[i',
    goto_bottom = ']i',
  },
  static = {
    enabled = false,
    char = '▎',
    priority = 1,
  },
  scope = {
    enabled = true,
    indent_at_cursor = true,
    char = '▎',
    priority = 100,
  },
})
