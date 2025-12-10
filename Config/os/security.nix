{ inputs, ... }:
{
  imports = [
    inputs.dankMaterialShell.nixosModules.greeter
  ];
  security.sudo-rs.enable = true;
  programs.dankMaterialShell.greeter = {
    compositor.name = "niri";
    quickshell.package = inputs.quickshell.packages.x86_64-linux.default;
    enable = true;
    configHome = "/home/rplakama/";
  };
}
