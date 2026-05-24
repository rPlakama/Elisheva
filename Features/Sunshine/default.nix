{ config, lib, ... }:

let
  cfg = config.features.sunshine;
in
{
  options.features.sunshine.enable = lib.mkEnableOption "Sunshine game streaming";
  config = lib.mkIf cfg.enable {
    features.preservation.persistDirs.system = [ "/var/lib/sunshine" ];

    services.sunshine = {
      enable = true;
      openFirewall = true;
      autoStart = true;
    };
  };
}