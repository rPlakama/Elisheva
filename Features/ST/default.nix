{
  config,
  lib,
  ...
}:

{
  options.optionals.features.ST.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "ST, AI RPG Service";
  };
  config = lib.mkIf config.optionals.features.ST.enable {
    networking.firewall.allowedTCPPorts = [ 6720 ];
    services.sillytavern = {
      enable = true;
      port = 6720;
      listen = true;
      listenAddressIPv4 = "0.0.0.0";
    };
  };
}
