{
  isDesktop,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./programs
  ]
  ++ lib.optionals isDesktop [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    ./programs/niri.nix
    ./programs/dms.nix
  ];

  home = {
    stateVersion = "26.05";
  };
}
