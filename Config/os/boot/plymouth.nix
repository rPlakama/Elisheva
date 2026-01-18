{ config, ... }:
{
  boot.plymouth = {
    enable = config.networking.hostName == "Centuria" || config.networking.hostName == "Elisheva";
    theme = "bgrt";
  };
}
