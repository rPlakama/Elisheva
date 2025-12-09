{
  config,
  lib,
  ...
}: {
  services = lib.mkMerge [
    {
      scx.enable = true;
      upower.enable = true;
    }
    (lib.mkIf (config.networking.hostName == "Elisheva") {
      tuned = {
        enable = true;
        settings.dynamic_tuning = true;
      };
      scx = {
        scheduler = "scx_bpfland";
        extraArgs = [
          "-s 20000 -m powersave -I 100 -t 100"
        ];
      };
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
