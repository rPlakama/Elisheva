{
  inputs,
  config,
  lib,
  ...
}:

let

  # nCall = "noctalia msg";
  nCallPanel = "noctalia msg";
  featureCall = config.features;

in

{

  imports = [
    inputs.umbriel.nixosModules.default
  ];

  options.features.umbriel.enable = lib.mkEnableOption "Umbriel Configuration";

  config = lib.mkIf featureCall.noctalia.enable {

    hjem.extraModules = [
      inputs.umbriel.hjemModules.default
    ];

    programs.umbriel = {
      settings = {
        keybinds = {
          "Mod+Space" = "spawn:${nCallPanel} launcher";
          "Mod+V" = "spawn:${nCallPanel} clipboard";
          "Ctrl+Alt+A" = "spawn:${nCallPanel} control-center";
        };
        hot_corners.bottom_right = {
          enabled = true;
          delay_ms = 500;
          action = "spawn:${nCallPanel} launcher";
        };
      };
    };
  };
}
