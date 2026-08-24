{
  inputs,
  config,
  lib,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    types
    ;
  inherit (types) bool;

  nCall = "noctalia msg";
  nCallPanel = "noctalia msg";
  keyboardLayout = config.core.keyboardLayout;
  featureCall = config.features;

in
{

  options.features.umbriel = {
    enable = mkEnableOption "Umbriel Configuration";
    type = bool;
  };

  imports = [
    inputs.umbriel.nixosModules.default
  ];

  hjem.extraModules = [
    inputs.umbriel.hjemModules.default
  ];

  programs.umbriel = {
    enable = true;
    settings = {
      general.autostart = [ "noctalia" ];
      layout.gap = 5;
      input.keyboard = {
        layout = keyboardLayout;
      };
      keybinds = {
        "Mod+Return" = "spawn:foot"; # Shall be var
        "Mod+W" = "window-close";
        "Mod+Space" = "spawn:${nCallPanel} launcher";
        "Mod+V" = "spawn:${nCallPanel} clipboard";
        "Ctrl+Alt+A" = "spawn:${nCallPanel} control-center";
      };
    };
  };
}
