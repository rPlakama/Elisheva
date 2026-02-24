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
      scheduler = if config.networking.hostName == "Elisheva" then "scx_bpfland" else "scx_rusty";
      enable = true;
    };
    # Using Tuned instead of power-profiles-daemon
    tuned.enable = config.networking.hostName == "Moontier" || config.networking.hostName == "Elisheva";
    power-profiles-daemon.enable = lib.mkForce false;

    # --- Storage
    devmon.enable = true;
    udisks2.enable = true;

    # --- Audio
    pipewire.alsa.enable = true;

    # --- Package Management
    flatpak.enable = config.networking.hostName == "Centuria";
  };

  # --- Virtualisation & Containers
  hardware.nvidia-container-toolkit.enable = config.networking.hostName == "Centuria";

  virtualisation.podman = {
    enable = isDesktop;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
}
