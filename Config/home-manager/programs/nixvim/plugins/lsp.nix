{ ... }:

{
  programs.nixvim.plugins = {
    lsp.enable = true;
    lazydev.enable = true;
    treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
    };
  };
}
