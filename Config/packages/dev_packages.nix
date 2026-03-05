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
    ]
    ++ lib.optionals isDesktop [
      jq
      typst
      nodejs
      android-studio
    ];
}
