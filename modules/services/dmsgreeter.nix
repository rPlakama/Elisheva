{ inputs, pkgs, ... }:

{
  imports = [
  inputs.dankMaterialShell.nixosModules.greeter
];
  programs.dankMaterialShell.greeter = {
    enable = true;
    compositor.name = "niri"; 
    configHome = "/home/user";
  };
}
