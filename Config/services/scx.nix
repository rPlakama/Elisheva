{ config, ... }:
{
  services.scx.enable = true;

  services.scx.scheduler =
    if config.networking.hostName == "Elisheva" then "scx_rustland" else "scx_lavd";
}
