{
  config,
  lib,
  ...
}:
{
  services = lib.mkMerge [
    {
      scx.enable = true;
      upower.enable = true;
    }

    (lib.mkIf (config.networking.hostName == "Elisheva") {
      power-profiles-daemon.enable = true;
      scx.scheduler = "scx_lavd";
    })

    (lib.mkIf (config.networking.hostName == "Centuria") {
      scx.scheduler = "scx_rusty";
      bpftune.enable = true;
    })
  ];
}
