{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # LUA
    lua-language-server
    # NIX
    nixd
    # TYPST
    typst
    tinymist
    typstyle

    # Others
    nodejs
    kdlfmt
    fish-lsp
  ];
}
