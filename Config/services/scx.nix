{ lib, config, ... }:
{
  services.scx.enable = true;

  services.scx.scheduler =
    if config.networking.hostName == "Centuria" then "scx_rusty"
    else "scx_lavd";
}
