{
  isDesktop,
  config,
  ...
}:
{
  services = {
    upower.enable = true;
    bpftune.enable = true;

    scx = {
      enable = true;
      scheduler = if config.networking.hostName == "Elisheva" then "scx_lavd" else "scx_rusty";
      extraArgs = if config.networking.hostName == "Elisheva" then [ "--powersave" ] else [ ];
    };

    devmon.enable = true;
    udisks2.enable = true;
    pipewire.alsa.enable = true;
    flatpak.enable = isDesktop;
  };

  hardware.nvidia-container-toolkit.enable = config.networking.hostName == "Centuria";
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };
}
