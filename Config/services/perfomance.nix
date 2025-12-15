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
      tuned = {
        enable = true;
        settings = {
          dynamic_tuning = true;
        };
      };
      scx.scheduler = "scx_rustland";
    })

    (lib.mkIf (config.networking.hostName == "Centuria") {
      scx.scheduler = "scx_rusty";
      bpftune.enable = true;
    })
  ];
}
