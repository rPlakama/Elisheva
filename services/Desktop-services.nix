{ lib, inputs, ... }:
{

  imports = [
    inputs.dms.nixosModules.dank-material-shell
  ];

  services = {
    power-profiles-daemon.enable = lib.mkForce false;
    flatpak.enable = true;
    pipewire.alsa.enable = true;

    displayManager.dms-greeter = {
      enable = true;
      compositor = {
        name = "niri";
      };
      configHome = "/home/rplakama";
    };

  };
  programs.dank-material-shell = {
    # <-- If it runs as a systemd unit it is a service and nothing will change my mind.
    enable = true;
    enableCalendarEvents = false;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
  };
  virtualisation = {
    libvirtd.enable = true;
    docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune.enable = true;
    };
  };

}
