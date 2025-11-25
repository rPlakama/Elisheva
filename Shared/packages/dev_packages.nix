{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    lua-language-server
    # NIX
    nixd
    # TYPST
    typst
    tinymist
    # Others
    nodejs
    fish-lsp
    jq

  ];
}
