{ config, lib, ... }:

let

  cfg = config.optionals.features.neovim;
in
{
  options.optionals.features.sunshine.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Sunshine, transmit desktop to any host";
    default = false;
  };
  config = lib.mkIf cfg.enable {
    services.sunshine = {
      enable = true;
      openFirewall = true;
      autoStart = true;
    };
  };
}
