{
  lib,
  config,
  ...
}:

let
  cfg = config.features.iperf3;
in
{
  options.features.iperf3.enable = lib.mkEnableOption "iperf3 network testing";
  config = lib.mkIf cfg.enable {
    services.iperf3 = {
      enable = true;
      port = 5201;
    };
  };
}
