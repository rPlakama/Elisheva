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
      scx.scheduler = "scx_rusty";
    })

    (lib.mkIf (config.networking.hostName == "Centuria") {
      scx = {
        scheduler = "scx_lavd";
        extraArgs = [
          "--performance"
        ];
      };
    })
  ];
}
