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
      fish-lsp
      nixd
    ]
    ++ lib.optionals isDesktop [
      jq
      typst
      nodejs
      lua-language-server
      android-studio
    ];
}
