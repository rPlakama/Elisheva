{ inputs, ... }:
{
  imports = [
    inputs.dms.nixosModules.dank-material-shell
  ];

  services = {
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
