{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.optionals.features.steam;
in

{
  options.optionals.features.steam.enable = lib.mkOption {
    type = lib.types.bool;
    description = "steam Configuration";
    default = true;
  };
  config = lib.mkIf cfg.enable {
    programs = {
      steam = {
        enable = true;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
      };
    };
  };
}
