{ config, ... }:
{
  services.tuned.enable = config.networking.hostName == "Moontier" || config.networking.hostName == "Elisheva";
}
