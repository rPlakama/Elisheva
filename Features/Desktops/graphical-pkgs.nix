{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    types
    concatStringsSep
    ;
  inherit (types) bool str listOf;

  cfg = config.features.graphicalPkgs;
  user = config.core.user;
  headless = config.core.headless;
in
{
  options.features.graphicalPkgs = {
    enable = mkOption {
      type = bool;
      default = !headless;
      description = "Graphical Packages";
    };
    foot.theme = mkOption {
      type = listOf str;
      default = [ ];
      description = "Import themes for Foot";
      example = "include=path";
    };
    foot.font = mkOption {
      type = str;
      default = "CaskaydiaCove Nerd Font Mono:size=9";
      description = "Foot terminal font (family:size=pts)";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      inputs.helium-browser.packages.x86_64-linux.default
      # This need to be solved: x86_64-linux is a >problem< if other hosts arent in such platform, \
      # Causing rebuild errors; For the future, \
      # there's shall be a inherence based on Host (core option) to choose which type; \
      vesktop
      materialgram
      nextcloud-client
      jellyfin-desktop
      foot
      mpv
      ripdrag
      obsidian
      kdePackages.okular
      gnome-disk-utility
      motrix-next
    ];

    hjem.users.${user} = {
      files.".config/foot/foot.ini".text = ''
        [main]
        dpi-aware=false
        font=${cfg.foot.font}
      ''
      + "\n"
      + (concatStringsSep "\n" cfg.foot.theme);
    };
  };
}
