{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    lua-language-server
    # NIX
    nixd
    # TYPST
    typst
    tinymist
    # Others
    nixfmt-rfc-style
    nodejs
    fish-lsp
    jq
    git
  ];
}
