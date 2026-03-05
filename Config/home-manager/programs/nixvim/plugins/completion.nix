{ ... }:

{
  programs.nixvim.plugins = {
    blink-cmp = {
      enable = true;
      settings = {
        keymap.preset = "default";
        snippets.preset = "luasnip";
        sources.default = [ "lsp" "path" "snippets" "buffer" ];
      };
    };
    luasnip.enable = true;
    friendly-snippets.enable = true;
  };
}
