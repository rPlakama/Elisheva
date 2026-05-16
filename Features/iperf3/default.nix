{
  lib,
  config,
  ...
}:

let

  cfg = config.optionals.features.iperf3;

in
{
  options.optionals.features.iperf3.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Iperf3";
    default = false;
  };
  config = lib.mkIf cfg.enable {
    services.iperf3 = {
      enable = true;
      port = 5201;
    };
  };
}
