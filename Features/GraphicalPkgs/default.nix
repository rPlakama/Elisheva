{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.optionals.features.graphicalPkgs;
in
{
  options.optionals.features.graphicalPkgs.enable = lib.mkOption {
    description = "Graphical Packages";
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      firefox
      materialgram
      jellyfin-desktop
    ];
  };
}
