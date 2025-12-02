{
  osConfig,
  lib,
  ...
}: {
  services.scx = lib.mkMerge [
    {enable = true;}
    (lib.mkIf (osConfig.networking.hostName == "Elisheva") {
      scheduler = "scx_lavd";
    })

    (lib.mkIf (osConfig.networking.hostName == "Centuria") {
      scheduler = "scx_bpfland";
    })
  ];
}
