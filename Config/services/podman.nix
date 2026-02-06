{ config, pkgs, ... }:
{
  virtualisation.podman = {
    enable = config.networking.hostName == "Centuria" || config.networking.hostName == "Elisheva";
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  hardware.nvidia-container-toolkit.enable = config.networking.hostName == "Centuria";
}
