{ config, ... }:
{
  services.bpftune.enable = config.networking.hostName == "Moontier" || config.networking.hostName == "Centuria";
}
