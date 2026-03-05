{ ... }:

{
  programs.nixvim.keymaps = [
    # LSP
    { mode = "n"; key = "<leader>lf"; action.__raw = "function() vim.lsp.buf.format() end"; options.desc = "Format"; }
    
    # Fzf-lua
    { mode = "n"; key = "<leader>fs"; action = "<cmd>FzfLua files<CR>"; options.desc = "Find Files"; }
    { mode = "n"; key = "<leader>fg"; action = "<cmd>FzfLua live_grep<CR>"; options.desc = "Live Grep"; }
    { mode = "n"; key = "<leader>fa"; action = "<cmd>FzfLua buffers<CR>"; options.desc = "Buffers"; }
    { mode = "n"; key = "<leader>s"; action = "<cmd>FzfLua spell_suggest<CR>"; options.desc = "Spell Suggest"; }
    
    # Oil
    { mode = [ "n" "v" ]; key = "<C-n>"; action = "<cmd>Oil<CR>"; options.desc = "Open Parent Directory (Oil)"; }
    
    # Spell
    { mode = "n"; key = "<C-1>"; action = "<cmd>setlocal spell spelllang=pt | echo 'Spell Portuguese(PT)'<CR>"; options = { silent = true; desc = "Spell PT"; }; }
    { mode = "n"; key = "<C-2>"; action = "<cmd>setlocal spell spelllang=en_us | echo 'Spell English(US)'<CR>"; options = { silent = true; desc = "Spell EN"; }; }
    { mode = "n"; key = "<C-3>"; action = "<cmd>setlocal nospell | echo 'Spell Disabled'<CR>"; options = { silent = true; desc = "Spell Off"; }; }
    
    # Path
    { 
      mode = "n"; 
      key = "<leader>pa"; 
      action.__raw = ''
        function()
          local p = vim.fn.expand('%:p:h')
          vim.fn.setreg('+', p)
          print('Current Location: ' .. p)
        end
      ''; 
      options.desc = "Copy path"; 
    }
    { mode = "n"; key = "<leader>cd"; action = "<cmd>cd %:p:h<CR>"; options = { silent = true; desc = "CD to current"; }; }

    # Tabs
    { mode = "n"; key = "<M-0>"; action = "<cmd>tabn10<CR>"; }
    { mode = "n"; key = "<M-w>"; action = "<cmd>tabclose<CR>"; }
    { mode = "n"; key = "<M-t>"; action = "<cmd>tabnew<CR>"; }

    # Move lines
    { mode = "n"; key = "<C-A-j>"; action = ":m .+1<CR>=="; options.desc = "Move line down"; }
    { mode = "n"; key = "<C-A-k>"; action = ":m .-2<CR>=="; options.desc = "Move line up"; }
    { mode = "v"; key = "<M-h>"; action = "<gv"; options.desc = "Indent left"; }
    { mode = "v"; key = "<M-l>"; action = ">gv"; options.desc = "Indent right"; }
  ] ++ (map (i: {
    mode = "n";
    key = "<M-${toString i}>";
    action = "<cmd>tabn${toString i}<CR>";
  }) [ 1 2 3 4 5 6 7 8 9 ]);
}
