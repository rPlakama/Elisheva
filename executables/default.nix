{
  lib,
  isCenturia,
  isDesktop,
  ...
}:
{
  imports = [
    ./term.nix
  ]
  ++ lib.optionals isCenturia [
    ./Centuria-graphical.nix
  ]
  ++ lib.optionals isDesktop [
    ./graphical.nix
  ];
}
