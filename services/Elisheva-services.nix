{ lib, inputs, ... }:
{
  imports = [
    inputs.dms.nixosModules.dank-material-shell
  ];

  programs.dank-material-shell = {
    enable = true;
    enableCalendarEvents = false;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
  };

  services = {
    power-profiles-daemon.enable = lib.mkForce false;
    displayManager.dms-greeter = {
      enable = true;
      compositor = {
        name = "niri";
      };
      configHome = "/home/rplakama";
    };

  };
}
