{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.graphicalPkgs;
  user = config.core.user;
  niriEnabled = config.features.niri.enable;
in
{
  options.features.graphicalPkgs.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Graphical Packages";
  };

  config = lib.mkIf cfg.enable {
    features.preservation.persistDirs.home = [
      ".config/vesktop"
      ".config/foot"
      ".config/mozilla"
    ];

    environment.systemPackages = with pkgs; [
      vesktop
      materialgram
      nextcloud-client
      foot
      mpv
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
