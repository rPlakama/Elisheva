{
  config,
  inputs,
  ...
}:
{
  imports = [
    inputs.dms.nixosModules.dank-material-shell
  ];

  programs.dank-material-shell = {
    enable = config.networking.hostName == "Elisheva" || config.networking.hostName == "Centuria";
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
  };

  services.hardware.openrgb = {
    enable = config.networking.hostName == "Centuria";
    motherboard = "amd";
  };

  services.displayManager.dms-greeter = {
    enable = config.networking.hostName == "Elisheva" || config.networking.hostName == "Centuria";
    compositor = {
      name = "niri";
    };
    configHome = "/home/rplakama";
  };
}
