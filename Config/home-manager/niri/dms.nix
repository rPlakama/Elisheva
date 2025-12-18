{ inputs, ... }:
{
  imports = [
    inputs.dankMaterialShell.homeModules.dankMaterialShell.default
    inputs.dankMaterialShell.homeModules.dankMaterialShell.niri
  ];

  programs.dank-material-shell = {
    enable = true;
    default.settings = ./settings.json;
    systemd.enable = true;
    niri.enableKeybinds = false;
    niri.enableSpawn = false;
    enableDynamicTheming = true;
    quickshell.package = inputs.quickshell.packages.x86_64-linux.default;
  };
}
