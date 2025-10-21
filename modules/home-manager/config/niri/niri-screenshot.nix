{config, ...}: {
  programs.niri.settings.binds = with config.lib.niri.actions; let
    sh = spawn "sh" "-c";
  in {
    "Print".action = sh ''grim -g "$(slurp)" - | wl-copy'';
  };
}
