{ ... }:

{
  programs.nixvim.plugins = {
    lualine.enable = true;
    gitsigns.enable = true;
    which-key.enable = true;
    todo-comments.enable = true;
    indent-blankline.enable = true;
    oil.enable = true;
    fzf-lua = {
      enable = true;
      settings.winopts.preview.default = "bat";
    };

    mini = {
      enable = true;
      modules = {
        pairs = { };
        surround = { };
        icons = { };
      };
    };
  };
}
