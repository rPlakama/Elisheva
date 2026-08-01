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
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      inputs.helium-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
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
        font=${config.features.theming.monoFont}:size=${toString config.features.theming.monoFontSize}
      ''
      + "\n"
      + (concatStringsSep "\n" cfg.foot.theme);
    };
  };
}
