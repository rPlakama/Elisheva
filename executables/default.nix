{
  lib,
  isCenturia,
  ...
}:
{
  imports = [
    ./term.nix
  ]
  ++ lib.optionals isCenturia [
    ./Centuria-graphical.nix
  ];
}
