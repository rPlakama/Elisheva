{ config, inputs, ... }:
{

  imports = [
    inputs.dms.nixosModules.dank-material-shell
    inputs.dms-plugin-registry.modules.default
  ];


  programs.dank-material-shell = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
  };

  services.displayManager.dms-greeter = {
    enable = config.networking.hostName == "Elisheva" || config.networking.hostName == "Centuria";
    compositor = {
      name = "niri";
    };
    configHome = "/home/rplakama";
  };

}
