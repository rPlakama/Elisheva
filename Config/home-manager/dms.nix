{ inputs, ... }:
{
  imports = [
    inputs.dankMaterialShell.homeModules.dank-material-shell
  ];

  programs.dank-material-shell = {
    enable = true;
    systemd.enable = true;
    enableDynamicTheming = true;
    quickshell.package = inputs.quickshell.packages.x86_64-linux.default;
  };
}
