{ ... }:

{
  programs.nixvim.globals.mapleader = " ";
  programs.nixvim.globals.maplocalleader = "";

  programs.nixvim.opts = {
    # General
    number = true;
    relativenumber = true;
    clipboard = "unnamedplus";
    termguicolors = true;
    scrolloff = 999;
    signcolumn = "yes";
    cursorline = false;

    # Indentation
    shiftwidth = 2;
    tabstop = 2;
    softtabstop = 2;
    expandtab = true;
    smartindent = true;
    autoindent = true;

    # Search
    ignorecase = true;
    smartcase = true;
    hlsearch = false;
    incsearch = true;

    # Spell
    spell = true;
    spelllang = [ "en" "pt" ];

    # ETC
    undofile = true;
    mouse = "";
    backup = false;
    swapfile = false;
  };

  programs.nixvim.colorschemes.base16 = {
    enable = true;
    colorscheme = "chalk";
  };
}
