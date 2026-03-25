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
    ./programs/mpv.nix
    ./programs/niri.nix
    ./programs/dms.nix

    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    inputs.danksearch.homeModules.dsearch
  ];

  home = {
    stateVersion = "26.05";
  };
}
