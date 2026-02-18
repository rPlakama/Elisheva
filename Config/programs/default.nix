{ isDesktop, lib, ... }:
{
  imports = [
    ./neovim.nix
    ./fish.nix
    ./zoxide.nix
    ./firefox.nix
    ./steam.nix
  ] ++ lib.optional isDesktop ./niri.nix;
}