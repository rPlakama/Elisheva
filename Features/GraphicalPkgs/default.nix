{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.graphicalPkgs;
  user = config.core.user;
in
{
  options.features.graphicalPkgs = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Graphical Packages";
    };
    foot.theme = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Import themes for Foot";
      example = "include=path";
    };
  };

  config = lib.mkIf cfg.enable {
    features.preservation.persistDirs.home = [
      ".config/vesktop"
      ".config/foot" # Themes aren't implemented by hjem
      ".config/mozilla"
      ".config/Nextcloud"
    ];

    environment.systemPackages = with pkgs; [
      vesktop
      materialgram
      nextcloud-client
      jellyfin-desktop
      firefox-beta
      foot
      mpv
      ripdrag
      obsidian
    ];

    hjem.users.${user} = {
      files.".config/foot/foot.ini".text = ''
        [main]
        dpi-aware=false
        font=CaskaydiaCove Nerd Font Mono:size=9
      ''
      + "\n"
      + (lib.concatStringsSep "\n" cfg.foot.theme);
    };
  };
}
