{
  isDesktop,
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.dms.nixosModules.dank-material-shell
  ];

  programs.dank-material-shell = {
    enable = isDesktop;
    enableCalendarEvents = false;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
  };

  
  # -- What I can say.
  services.power-profiles-daemon.enable = lib.mkForce false;

  services.hardware.openrgb = {
    enable = config.networking.hostName == "Centuria";
    motherboard = "amd";
  };

  services.sunshine = {
    enable = config.networking.hostName == "Centuria";
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  services.displayManager.dms-greeter = {
    enable = isDesktop;
    compositor = {
      name = "niri";
    };
    configHome = "/home/rplakama";
  };
}
