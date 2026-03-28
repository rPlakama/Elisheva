{ lib, isDesktop, ... }:
{
  imports = [
    ./programs.nix
    ./neovim/neovim.nix
  ]
  ++ lib.optionals isDesktop [
    ./desktop-programs.nix
    ./desktop-niri.nix
  ];

  home.stateVersion = "25.05";
}
