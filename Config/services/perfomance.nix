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

    (lib.mkIf (config.networking.hostName == "Moontier") {
      tuned.enable = true;
      bpftune.enable = true;
      scx.scheduler = "scx_lavd";
    })

    (lib.mkIf (config.networking.hostName == "Elisheva") {
      scx.scheduler = "scx_lavd";
      tuned = {
        enable = true;
        settings.dynamic_tuning = true;
      };
    })

    (lib.mkIf (config.networking.hostName == "Centuria") {
      scx.scheduler = "scx_rusty";
      bpftune.enable = true;
    })
  ];
}
