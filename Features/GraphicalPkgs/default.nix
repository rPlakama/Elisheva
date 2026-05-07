{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.optionals.features.graphicalPkgs;
  user = config.core.user;
  niriEnabled = config.optionals.features.niri.enable;
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
      foot
      zed-editor
      ripdrag
    ];

    hjem.users.${user} = {
      files.".config/foot/foot.ini".text = ''
        [main]
        dpi-aware=false
        font=CaskaydiaCove Nerd Font Mono:size=9
      ''
      + lib.optionalString niriEnabled ''
        include=/home/${user}/.config/foot/dank-colors.ini
      '';
    };
  };
}
