{ config, ... }:
{
  services.tuned.enable = config.networking.hostName == "Moontier";
}
