{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # LUA
    lua-language-server
    # NIX
    nixd
    # TYPST
    typst
    tinymist
    # Others
    nodejs
    fish-lsp
  ];
}
