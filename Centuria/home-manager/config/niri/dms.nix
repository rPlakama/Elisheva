{inputs, ...}: {
  imports = [
    inputs.dankMaterialShell.homeModules.dankMaterialShell.default
    inputs.dankMaterialShell.homeModules.dankMaterialShell.niri
  ];

  programs.dankMaterialShell = {
    enable = true;
    systemd.enable = true;
    niri.enableKeybinds = false;
    niri.enableSpawn = false;
    enableDynamicTheming = false;
    quickshell.package = inputs.quickshell.packages.x86_64-linux.default;
  };
}
