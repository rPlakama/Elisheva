{ inputs, ... }:
{
  imports = [
    inputs.dankMaterialShell.nixosModules.greeter
  ];
  security.sudo-rs.enable = true;
  programs.dank-material-shell.greeter = {
    compositor.name = "niri";
    enable = true;
    configHome = "/home/rplakama/";
  };
}
