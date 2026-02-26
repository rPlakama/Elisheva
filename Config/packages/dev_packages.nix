{
  lib,
  isDesktop,
  pkgs,
  ...
}:
{
  environment.systemPackages =
    with pkgs;
    [
      git
      nixd
    ]
    ++ lib.optionals isDesktop [
      jq
      typst
      lua-language-server
      nixfmt-rfc-style
      fish-lsp
      nodejs
      android-studio
      tinymist
    ];
}
