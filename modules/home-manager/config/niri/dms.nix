{ inputs, ... }:

{

  imports = [
    inputs.dankMaterialShell.homeModules.dankMaterialShell.default
    inputs.dankMaterialShell.homeModules.dankMaterialShell.niri
  ];

  programs.dankMaterialShell = {
    enable = true;
    niri.enableKeybinds = true;
    niri.enableSpawn = false;
    enableDynamicTheming = false;
    enableVPN = false;
    enableNightMode = false;
    enableCalendarEvents = false;
    enableSystemd = true;
    quickshell.package = inputs.quickshell.packages.x86_64-linux.default;
  };

}
