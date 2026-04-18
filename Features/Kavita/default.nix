{
  config,
  lib,
  ...
}:

let
  cfg = config.optionals.features.kavita;
in

{
  options.optionals.features.kavita.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Kavita Configuration";
    default = false;
  };
  config = lib.mkIf cfg.enable {
    sops.secrets."kavita/token" = {
      owner = "kavita";
    };
    services.kavita = {
      enable = true;
      settings.Port = 3045;
      tokenKeyFile = config.sops.secrets."kavita/token".path;
    };
    networking.firewall.allowedTCPPorts = [ 3045 ];
  };
}
