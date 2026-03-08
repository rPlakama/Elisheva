{
  lib,
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
      scheduler = if config.networking.hostName == "Elisheva" then "scx_lavd" else "scx_rusty";
      enable = true;
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

  virtualisation.podman = {
    enable = isDesktop;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
}
