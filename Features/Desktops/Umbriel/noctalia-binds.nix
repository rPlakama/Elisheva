{ ... }:

let

  # nCall = "noctalia msg";
  nCallPanel = "noctalia msg";

in

{

  programs.umbriel = {
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

}
