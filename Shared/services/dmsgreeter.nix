{
  inputs,
  ...
}: {
  imports = [
    inputs.dankMaterialShell.nixosModules.greeter
  ];
  programs.dankMaterialShell.greeter = {
    enable = true;
    compositor.name = "niri";
    configHome = "/home/rplakama/";
    quickshell.package = inputs.quickshell.packages.x86_64-linux.default;
  };
}

