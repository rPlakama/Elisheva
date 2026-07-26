{
  keymaps = [
    {
      mode = "n";
      key = "<leader>t";
      action = "<cmd>sp term://fish<CR>";
      options.desc = "Terminal";
    }
    {
      mode = "n";
      key = "<leader>f";
      action = "<cmd>lua require('fzf-lua').files()<CR>";
      options.desc = "Search files";
    }
    {
      mode = "n";
      key = "<leader>g";
      action = "<cmd>lua require('fzf-lua').live_grep()<CR>";
      options.desc = "Grep search";
    }
    {
      mode = "n";
      key = "<leader>a";
      action = "<cmd>lua require('fzf-lua').buffers()<CR>";
      options.desc = "Buffer search";
    }
    {
      mode = "n";
      key = "<leader>s";
      action = "<cmd>lua require('fzf-lua').spell_suggest()<CR>";
      options.desc = "Spell suggestions";
    }
    {
      mode = "n";
      key = "<C-k>";
      action = "<cmd>Gitsigns toggle_current_line_blame<CR>";
      options.desc = "Blame toggle";
    }
    {
      mode = "n";
      key = "<S-C-k>";
      action = "<cmd>Gitsigns blame_line<CR>";
      options.desc = "Blame";
    }
    {
      mode = "n";
      key = "<C-n>";
      action = "<cmd>Oil<CR>";
      options.desc = "Open Oil file explorer";
    }
    {
      mode = [
        "n"
        "t"
      ];
      key = "<A-h>";
      action = "<cmd>wincmd h<CR>";
      options.desc = "Move to left window";
    }
    {
      mode = [
        "n"
        "t"
      ];
      key = "<A-l>";
      action = "<cmd>wincmd l<CR>";
      options.desc = "Move to right window";
    }
    {
      mode = [
        "n"
        "t"
      ];
      key = "<A-j>";
      action = "<cmd>wincmd j<CR>";
      options.desc = "Move to lower window";
    }
    {
      mode = [
        "n"
        "t"
      ];
      key = "<A-k>";
      action = "<cmd>wincmd k<CR>";
      options.desc = "Move to upper window";
    }
    {
      mode = "n";
      key = "<C-M-1>";
      action = "<cmd>lua vim.opt.spell = true; vim.opt.spelllang = 'en_us'; print('Spell: English (US)')<CR>";
      options.desc = "English spell check on";
    }
    {
      mode = "n";
      key = "<C-M-2>";
      action = "<cmd>lua vim.opt.spell = true; vim.opt.spelllang = 'pt_br'; print('Spell: Portuguese (BR)')<CR>";
      options.desc = "Portuguese BR spell check on";
    }
    {
      mode = "n";
      key = "<C-M-3>";
      action = "<cmd>lua vim.opt.spell = false; print('Spell: Off')<CR>";
      options.desc = "Spell check off";
    }
    {
      mode = "n";
      key = "<leader>lf";
      action = "<cmd>lua vim.lsp.buf.format({ async = true })<CR>";
      options.desc = "LSP Format buffer";
    }
    {
      mode = "n";
      key = "gd";
      action = "<cmd>lua vim.lsp.buf.definition()<CR>";
      options.desc = "Go to definition";
    }
    {
      mode = "n";
      key = "<leader>d";
      action = "<cmd>lua vim.diagnostic.open_float()<CR>";
      options.desc = "Diagnostics float";
    }
    {
      mode = "n";
      key = "<leader>bd";
      action = "<cmd>lua vim.cmd('bd'); vim.cmd(\"echo 'Buffer deleted'\")<CR>";
      options.desc = "Delete buffer";
    }
    {
      mode = "n";
      key = "q:";
      action = ":";
    }
    {
      mode = "i";
      key = "<C-BS>";
      action = "<C-W>";
      options.desc = "Delete word";
    }
    {
      mode = "n";
      key = "ss";
      action = "<cmd>lua require('flash').jump()<CR>";
      options.desc = "Flash jump";
    }
    {
      mode = "n";
      key = "S";
      action = "<cmd>lua require('flash').treesitter()<CR>";
      options.desc = "Flash treesitter";
    }
    {
      mode = "n";
      key = "<leader>r";
      action = "<cmd>lua require('flash').remote()<CR>";
      options.desc = "Flash remote";
    }
    {
      mode = "n";
      key = "<leader>R";
      action = "<cmd>lua require('flash').treesitter_search()<CR>";
      options.desc = "Flash treesitter search";
    }
    {
      mode = "n";
      key = "<C-T>l";
      action = "<cmd>tabnext<CR>";
      options.desc = "Next tab";
    }
    {
      mode = "n";
      key = "<C-T>h";
      action = "<cmd>tabprevious<CR>";
      options.desc = "Prev tab";
    }
    {
      mode = "n";
      key = "<C-T>j";
      action = "<cmd>tabnew<CR>";
      options.desc = "New tab";
    }
    {
      mode = "n";
      key = "<C-T>q";
      action = "<cmd>tabclose<CR>";
      options.desc = "Close tab";
    }
  ];

  extraConfigLua = builtins.readFile ./keybinds.lua;
}
