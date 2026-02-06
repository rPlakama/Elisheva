{ inputs, ... }:
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    ./programs
  ];

  home = {
    stateVersion = "25.05";
  };
}
