{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit
    (lib)
    mkOption
    mkIf
    types
    concatStringsSep
    optionals
    ;
  inherit (types) bool str listOf;

  user = config.core.user;
  headless = config.core.headless;
  featureCall = config.features;
in {
  options.features.graphicalPkgs = {
    enable = mkOption {
      type = bool;
      default = !headless;
      description = "Graphical Packages";
    };
    foot.theme = mkOption {
      type = listOf str;
      default = [];
      description = "Import themes for Foot";
      example = "include=path";
    };
  };

  config = mkIf featureCall.graphicalPkgs.enable {
    hjem.users.${user} = {
      packages = with pkgs;
        [
          inputs.helium-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
          vesktop
          materialgram
          nextcloud-client
          foot
          mpv
          ripdrag
          obsidian
          kdePackages.okular
          motrix-next
        ]
        ++ optionals (config.core.isLaptop.enable) [
          moonlight-qt
        ];

      files.".config/foot/foot.ini".text =
        ''
          [main]
          dpi-aware=false
          font=${featureCall.theming.monoFont}:size=${toString featureCall.theming.monoFontSize}
        ''
        + "\n"
        + (concatStringsSep "\n" featureCall.graphicalPkgs.foot.theme);
    };
  };
}
