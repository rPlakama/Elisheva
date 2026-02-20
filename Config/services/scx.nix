{ config, ... }:
{
  services = {
    scx = {
      scheduler = if config.networking.hostName == "Elisheva" then "scx_bpfland" else "scx_rusty";
      enable = true;
    };
  };

}
