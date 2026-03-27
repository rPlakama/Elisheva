{ lib, isDesktop, ... }:
{
  imports = [
    ./mpv.nix
    ./cli.nix
    ./neovim/neovim.nix
  ]
  ++ lib.optionals isDesktop [
    ./dms.nix
    ./mpv.nix
    ./niri.nix
  ];
}
