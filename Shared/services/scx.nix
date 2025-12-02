{
  config,
  lib,
  ...
}: {
  services.scx = lib.mkMerge [
    {
      enable = true;
    }
    (lib.mkIf (config.networking.hostName == "Elisheva") {
      scheduler = "scx_lavd";
      extraArgs = [
      "--powersave"
      ];
      
    })

    (lib.mkIf (config.networking.hostName == "Centuria") {
      scheduler = "scx_lavd";
      extraArgs = [
      "--perfomance"
      ];
    })
  ];
}
