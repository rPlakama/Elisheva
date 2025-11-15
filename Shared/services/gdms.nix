{
  inputs,
  ...
}: {
  programs.dankMaterialShell.greeter = {
  compositor = {
    name = "niri"; 
  };

  configHome = "/home/rplakama/";

  logs = {
    save = true; 
    path = "/tmp/dms-greeter.log";
  };

  quickshell.package = inputs.quickshell.packages.x86_64-linux.default;

};
}
