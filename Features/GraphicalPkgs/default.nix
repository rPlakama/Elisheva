{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.optionals.features.graphicalPkgs;
  user = config.core.user;

in
{
  options.optionals.features.graphicalPkgs.enable = lib.mkOption {
    description = "Graphical Packages";
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      vesktop
      firefox
      materialgram
      jellyfin-desktop
    ];

    home-manager.users.${user} = {
      programs.foot = {
        enable = true;
        settings.main = {
          dpi-aware = false;
          font = "CaskaydiaCove Nerd Font Mono:size=9";
          include = "/home/${user}/.config/foot/dank-colors.ini";
        };
      };
    };
  };
}
