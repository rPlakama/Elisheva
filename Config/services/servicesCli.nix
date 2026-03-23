{
  isDesktop,
  config,
  ...
}:
{
  services = {
    # --- Performance & Power Management
    upower.enable = true;
    bpftune.enable =
      config.networking.hostName == "Moontier" || config.networking.hostName == "Centuria";

    scx = {
      enable = true;
      scheduler = if config.networking.hostName == "Elisheva" then "scx_lavd" else "scx_rusty";
      extraArgs = if config.networking.hostName == "Elisheva" then [ "--powersave" ] else [ ];
    };

    # --- Storage
    devmon.enable = true;
    udisks2.enable = true;

    # --- Audio
    pipewire.alsa.enable = true;

    # --- Package Management
    flatpak.enable = isDesktop;
  };

  # --- Virtualisation & Containers
  hardware.nvidia-container-toolkit.enable = config.networking.hostName == "Centuria";

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };
}
