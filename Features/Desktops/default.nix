{
  imports = [
    ./dankMaterialShell
    ./Noctalia
    ./Niri
  ];

  boot.consoleLogLevel = 0;
  services.displayManager.ly = {
    enable = true;
    settings = {
      default_input = "password";
      bigclock = true;
    };
  };
}
