{
  globals = {
    mapleader = " ";
    maplocalleader = ",";
  };

  colorschemes.base16 = {
    enable = true;
  };

  opts = {
    expandtab = false;
    shiftwidth = 2;
    tabstop = 2;
    softtabstop = 2;
    number = true;
    relativenumber = true;
    termguicolors = true;
    clipboard = "unnamedplus";
    cursorline = true;
    mouse = "";
    wrap = true;
    hlsearch = false;
    incsearch = true;
    autoindent = true;
    swapfile = false;
    backup = false;
    undofile = true;
    splitbelow = true;
    splitright = true;
    winborder = "rounded";
    exrc = true;
  };

  extraConfigLua = builtins.readFile ./configs.lua;
}
