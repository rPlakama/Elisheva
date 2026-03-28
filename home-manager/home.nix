{ lib, isDesktop, ... }:
{
  imports = [
    ./programs.nix
  ]
  ++ lib.optionals isDesktop [
    ./desktop-programs.nix
    ./desktop-niri.nix
  ];

  home.stateVersion = "26.05";
}
