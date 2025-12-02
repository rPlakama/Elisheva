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
      tuned.enable = true;
      scx = {
        scheduler = "scx_rustland";
        extraArgs = [
          "--powersave"
        ];
      };
    })

    (lib.mkIf (config.networking.hostName == "Centuria") {
      scx = {
        scheduler = "scx_lavd";
        extraArgs = [
          "--perfomance"
        ];
      };
    })
  ];
}
