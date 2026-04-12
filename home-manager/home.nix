{
  isElisheva,
  lib,
  isDesktop,
  ...
}:
{
  imports = [
    ./programs.nix
    ./neovim/neovim.nix
  ]
  ++ lib.optionals isDesktop [
    ./desktop-programs.nix
  ]
  ++ lib.optionals isElisheva [
    ./desktop-niri.nix
  ];

  home.stateVersion = "26.05";
}
