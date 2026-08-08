-- Icons (mini.icons as nvim-web-devicons shim for oil/fzf-lua/blink-cmp)
require('mini.icons').setup()
MiniIcons.mock_nvim_web_devicons()

-- Comment
require('mini.comment').setup()

-- Surround (ys/ds/cs style)
require('mini.surround').setup()

-- Autopairs
require('mini.pairs').setup()

-- Trailing whitespace trimming (replaces the inline %s/\s\+$//e in configs.lua)
require('mini.trailspace').setup()

-- TODO/FIXME/NOTE highlighting in comments
require('mini.hipatterns').setup({
  highlighters = {
    fixme = { pattern = 'FIXME', group = 'MiniHipatternsFixme' },
    todo = { pattern = 'TODO', group = 'MiniHipatternsTodo' },
    note = { pattern = 'NOTE', group = 'MiniHipatternsNote' },
  },
})

-- Snippets removed: mini.snippets sessions corrupted extmarks (deleted/out of
-- range) when buffers were switched/loaded mid-session, which made fzf-lua's
-- buffer loading fail ("Unable to add buffer"). Revisit with a guarded setup
-- if snippets are wanted back.

-- Clue (which-key style leader hints)
local MiniClue = require('mini.clue')
MiniClue.setup({
  triggers = {
    { mode = { 'n', 'x' }, keys = '<Leader>' },
    { mode = 'n', keys = '<C-T>' },
    { mode = { 'n', 'x' }, keys = '[' },
    { mode = { 'n', 'x' }, keys = ']' },
  },
  clues = {
    MiniClue.gen_clues.builtin_completion(),
    MiniClue.gen_clues.g(),
    MiniClue.gen_clues.marks(),
    MiniClue.gen_clues.registers(),
    MiniClue.gen_clues.windows(),
    MiniClue.gen_clues.z(),
    { mode = { 'n', 'x' }, keys = '<Leader>l', desc = '+LSP' },
    { mode = 'n', keys = '<Leader>r', desc = '+Flash' },
    { mode = { 'n', 'x' }, keys = '<Leader>b', desc = '+Buffer' },
    { mode = 'n', keys = '<C-T>l', desc = 'Next tab' },
    { mode = 'n', keys = '<C-T>h', desc = 'Prev tab' },
    { mode = 'n', keys = '<C-T>j', desc = 'New tab' },
    { mode = 'n', keys = '<C-T>q', desc = 'Close tab' },
    { mode = { 'n', 'x' }, keys = '[d', desc = 'Prev diagnostic' },
    { mode = { 'n', 'x' }, keys = ']d', desc = 'Next diagnostic' },
    { mode = { 'n', 'x' }, keys = '[i', desc = 'BlinkIndent scope' },
    { mode = { 'n', 'x' }, keys = ']i', desc = 'BlinkIndent scope' },
  },
})
